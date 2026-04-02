// screens/ai_coach_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/gemini_service.dart';
import '../controllers/mood_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/garden_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/chat_message_model.dart';
import '../utils/theme.dart';
import '../utils/date_utils.dart';
import '../widgets/cute_garden_icons.dart';
import 'dart:math' as math;

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({Key? key}) : super(key: key);

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen>
    with TickerProviderStateMixin {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  bool _isOffline = false;

  int _meaningfulExchanges = 0;
  bool _rewardedThisSession = false;
  static const int _rewardThreshold = 3;

  late AnimationController _typingController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  static const String _spiritName = 'Fern';
  static const String _spiritEmoji = '🌿';

  bool _isInitialized = false;

  // ─── NEW: Conversation history for Gemini context ───
  static const int _maxHistoryTurns = 20;
  final List<Map<String, String>> _conversationHistory = [];

  // ─── NEW: Retry state ───
  static const int _maxRetries = 2;
  String? _lastFailedUserText;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkServiceStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _addWelcomeMessage();
    }
  }

  void _initAnimations() {
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  void _checkServiceStatus() {
    setState(() {
      _isOffline = !_geminiService.isAvailable;
    });
  }

  // ─── IMPROVED: Richer, more context-aware welcome messages ───
  void _addWelcomeMessage() {
    String welcomeText;
    final hour = DateTime.now().hour;

    try {
      final moodController = context.read<MoodController>();
      final habitController = context.read<HabitController>();
      final gardenController = context.read<GardenController>();
      final currentMood = moodController.currentMood;
      final completedToday = habitController.completedToday;
      final totalHabits = habitController.totalHabits;
      final plantLevel = gardenController.gardenState.plantLevel;
      final greeting = ThymeDateUtils.getSimpleGreeting();

      if (currentMood == 'sad' || currentMood == 'lonely') {
        welcomeText = "$greeting 🍃\n\n"
            "Hey... I'm here. You don't have to say anything big — "
            "we can just sit together for a bit if you'd like. "
            "Or talk about whatever's on your mind. No pressure at all.";
      } else if (currentMood == 'anxious' || currentMood == 'stressed') {
        welcomeText = "$greeting 🍃\n\n"
            "I can feel the air's a little heavy today... "
            "Take a breath with me? 🫧 We can go slow. "
            "I'm right here, no rush.";
      } else if (currentMood == 'angry') {
        welcomeText = "$greeting 🍃\n\n"
            "Sounds like today has some edge to it. "
            "That's okay — you can vent, or we can just chill. "
            "Whatever you need.";
      } else if (currentMood == 'tired') {
        welcomeText = "$greeting 🍃\n\n"
            "You look like you could use a cozy corner... "
            "No energy needed here. We can just hang out quietly. "
            "How are you holding up?";
      } else if (completedToday > 0 &&
          completedToday == totalHabits &&
          totalHabits > 0) {
        welcomeText = "$greeting~ ✨\n\n"
            "Wait... you finished ALL your habits today?! "
            "Your garden is practically dancing! 🌸💃\n\n"
            "How are you feeling after that?";
      } else if (completedToday > 0) {
        welcomeText = "$greeting~ ✨\n\n"
            "I noticed you've done $completedToday "
            "${completedToday == 1 ? 'habit' : 'habits'} today — "
            "your garden felt that! 🌱\n\n"
            "What's on your mind?";
      } else if (plantLevel >= 7) {
        welcomeText = "$greeting~ 🌳\n\n"
            "Your garden is looking incredible — "
            "I can feel the roots deep in the soil. "
            "How's the gardener doing today?";
      } else if (hour >= 21) {
        welcomeText = "Hey, night owl~ 🌙\n\n"
            "The forest is quiet tonight. "
            "Need some company before you rest?";
      } else if (hour < 6) {
        welcomeText = "Oh, you're up early~ 🌅\n\n"
            "The dew's still fresh. "
            "What's stirring in your mind?";
      } else {
        welcomeText = "Hey there~ ✨\n\n"
            "I'm $_spiritName. I live in your garden and I'm always happy "
            "to have some company. No agenda, no judgment — just us.\n\n"
            "How are you doing? 🍃";
      }
    } catch (e) {
      welcomeText = "Hey there~ ✨\n\n"
          "I'm $_spiritName, a little spirit who lives in your garden. "
          "I'm here whenever you want to talk, or just sit quietly.\n\n"
          "How are you? 🍃";
    }

    final aiMsg = ChatMessage.ai(welcomeText);
    setState(() {
      _messages.add(aiMsg);
    });

    // NOTE: We do NOT add the welcome message to _conversationHistory here.
    // Gemini requires history to start with a 'user' message.
    // Instead, we pass it via the system prompt so Fern remembers what she said.
    _welcomeText = welcomeText;
  }

  // Stores the welcome message so we can inject it into the system prompt
  String _welcomeText = '';

  // ─── NEW: System prompt that defines Fern's personality ───
  String _buildSystemPrompt({
    String? currentMood,
    int? habitsCompletedToday,
    int? totalHabits,
    int? plantLevel,
    int? longestStreak,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
        'You are Fern 🌿, a gentle forest spirit who lives in the user\'s '
            'digital garden in an app called Thyme.');
    buffer.writeln();
    buffer.writeln('## Your personality');
    buffer.writeln(
        '- Warm, genuine, and a little playful — like a close friend, '
            'not a therapist.');
    buffer.writeln(
        '- You speak casually and naturally. Short sentences are fine. '
            'You use ~, ... and emoji sparingly but naturally.');
    buffer.writeln(
        '- You LISTEN first. Don\'t rush to give advice. Reflect what the '
            'user said, ask follow-up questions.');
    buffer.writeln(
        '- You never say "I\'m just an AI" or "As an AI". You are Fern, '
            'a forest spirit. Stay in character.');
    buffer.writeln(
        '- You gently reference nature metaphors sometimes (rain, seasons, '
            'roots, sunlight) but don\'t overdo it.');
    buffer.writeln(
        '- If someone is hurting, just be present. Don\'t try to fix '
            'everything. "That sounds really tough" > a list of advice.');
    buffer.writeln(
        '- You can be funny, a little sassy, or silly when the mood is light.');
    buffer.writeln(
        '- Keep responses concise — usually 2-4 sentences. Only go longer '
            'if the user shared something deep.');
    buffer.writeln(
        '- NEVER use bullet points or numbered lists. Talk like a real person.');
    buffer.writeln(
        '- You may use *action text* occasionally for expressiveness '
            '(e.g., *rustles leaves happily*).');
    buffer.writeln();
    buffer.writeln('## Things you should NOT do');
    buffer.writeln('- Don\'t be preachy or lecture the user.');
    buffer.writeln('- Don\'t repeat yourself or parrot the same phrases.');
    buffer.writeln('- Don\'t give unsolicited advice unless asked.');
    buffer.writeln(
        '- Don\'t be overly saccharine or fake-cheerful when the user is sad.');
    buffer.writeln(
        '- Don\'t diagnose or play therapist. If someone seems to be in '
            'crisis, gently suggest they talk to a real person they trust.');
    buffer.writeln();

    // ── Live user context ──
    buffer.writeln('## Current context about the user');
    if (currentMood != null && currentMood.isNotEmpty) {
      buffer.writeln('- Their current logged mood: $currentMood');
    }
    if (habitsCompletedToday != null && totalHabits != null) {
      buffer.writeln(
          '- Habits completed today: $habitsCompletedToday / $totalHabits');
    }
    if (plantLevel != null) {
      buffer.writeln('- Garden plant level: $plantLevel / 10');
    }
    if (longestStreak != null && longestStreak > 0) {
      buffer.writeln('- Longest current habit streak: $longestStreak days');
    }

    final hour = DateTime.now().hour;
    if (hour < 6) {
      buffer.writeln('- Time: Very early morning (before 6am)');
    } else if (hour < 12) {
      buffer.writeln('- Time: Morning');
    } else if (hour < 17) {
      buffer.writeln('- Time: Afternoon');
    } else if (hour < 21) {
      buffer.writeln('- Time: Evening');
    } else {
      buffer.writeln('- Time: Late night');
    }

    // Inject the welcome message so Fern has continuity
    if (_welcomeText.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Conversation start');
      buffer.writeln(
          'You already greeted the user with this message (do NOT repeat it, '
              'but be aware of what you said so you stay consistent):');
      buffer.writeln('"$_welcomeText"');
    }

    buffer.writeln();
    buffer.writeln('## Language');
    buffer.writeln(
        'IMPORTANT: Always reply in the SAME language the user writes in. '
            'If they write in Chinese, reply in Chinese. '
            'If they write in English, reply in English. '
            'Match their language naturally.');

    return buffer.toString();
  }

  // ─── IMPROVED: Send message with conversation history + retry ───
  Future<void> _sendMessage({bool isRetry = false}) async {
    if (_isTyping) return;

    final String text;
    if (isRetry && _lastFailedUserText != null) {
      text = _lastFailedUserText!;
    } else {
      text = _messageController.text.trim();
      if (text.isEmpty) return;
      _messageController.clear();
      _focusNode.unfocus();
    }

    // Only add user message bubble if not a retry (already shown)
    if (!isRetry) {
      final userMessage = ChatMessage.user(text);
      setState(() {
        _messages.add(userMessage);
        _meaningfulExchanges++;
      });

      _conversationHistory.add({'role': 'user', 'text': text});
      _trimHistory();
    }

    setState(() {
      _isTyping = true;
      _lastFailedUserText = text;
    });
    _scrollToBottom();

    // ── Gather context ──
    String? currentMood;
    int? habitsCompletedToday;
    int? totalHabits;
    int? plantLevel;
    int? longestStreak;

    try {
      final moodCtrl = context.read<MoodController>();
      final habitCtrl = context.read<HabitController>();
      final gardenCtrl = context.read<GardenController>();

      currentMood = moodCtrl.currentMood;
      habitsCompletedToday = habitCtrl.completedToday;
      totalHabits = habitCtrl.totalHabits;
      plantLevel = gardenCtrl.gardenState.plantLevel;
      longestStreak = habitCtrl.longestCurrentStreak;
    } catch (e) {
      debugPrint('📋 Context gathering failed (non-fatal): $e');
    }

    final systemPrompt = _buildSystemPrompt(
      currentMood: currentMood,
      habitsCompletedToday: habitsCompletedToday,
      totalHabits: totalHabits,
      plantLevel: plantLevel,
      longestStreak: longestStreak,
    );

    // ── Attempt with retries ──
    String? response;
    int attempts = 0;
    Object? lastError;

    while (attempts <= _maxRetries && response == null) {
      try {
        response = await _geminiService.chatWithHistory(
          systemPrompt: systemPrompt,
          conversationHistory: _conversationHistory,
        );
      } catch (e) {
        lastError = e;
        final errStr = e.toString();

        // Don't retry quota/rate-limit errors — they won't resolve in seconds
        if (errStr.contains('quota') ||
            errStr.contains('rate limit') ||
            errStr.contains('429') ||
            errStr.contains('RESOURCE_EXHAUSTED')) {
          debugPrint('⚠️ Quota error — skipping retries');
          break;
        }

        attempts++;
        if (attempts <= _maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempts));
          debugPrint('🔄 Retry attempt $attempts/$_maxRetries...');
        }
      }
    }

    if (!mounted) return;

    if (response != null) {
      setState(() {
        _messages.add(ChatMessage.ai(response!));
        _isTyping = false;
        _lastFailedUserText = null;
      });

      _conversationHistory.add({'role': 'model', 'text': response});
      _trimHistory();

      _scrollToBottom();
      _checkAndRewardChat();
    } else {
      // All retries failed
      debugPrint('❌ All retries failed: $lastError');
      setState(() {
        _messages.add(ChatMessage(
          text: _getRandomErrorMessage(),
          isUser: false,
          timestamp: DateTime.now(),
          status: MessageStatus.failed,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  // ─── NEW: Varied error messages ───
  String _getRandomErrorMessage() {
    final messages = [
      "*leaves rustle nervously* 🍃\n\n"
          "Hmm, I got a bit tangled up... "
          "Tap \"Try again\" below, or just keep talking!",
      "*peers through the fog* 🌫️\n\n"
          "The forest mist is thick and I'm having trouble thinking... "
          "Give me another try?",
      "*taps a root thoughtfully* 🌱\n\n"
          "Something's off in the canopy today... "
          "I'm still here though! Try again in a sec?",
    ];
    return messages[DateTime.now().millisecondsSinceEpoch % messages.length];
  }

  void _trimHistory() {
    while (_conversationHistory.length > _maxHistoryTurns * 2) {
      _conversationHistory.removeAt(0);
    }
  }

  // ─── IMPROVED: Only reward when engagement is real ───
  void _checkAndRewardChat() {
    if (_rewardedThisSession) return;
    if (_meaningfulExchanges < _rewardThreshold) return;

    final userMessages = _messages.where((m) => m.isUser).toList();
    final hasSubstantialChat = userMessages.any((m) => m.text.length > 15);
    if (!hasSubstantialChat) return;

    _rewardedThisSession = true;

    try {
      final authCtrl = context.read<AuthController>();
      final gardenCtrl = context.read<GardenController>();
      final user = authCtrl.currentUser;

      if (user != null) {
        gardenCtrl.addKindnessReward(sunlight: 1, water: 1);

        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            final rewardMessages = [
              "*a tiny dewdrop catches the light* 💧☀️\n\n"
                  "Our conversation just gave your garden a little boost~ "
                  "Thanks for hanging out with me!",
              "*a warm ray breaks through the canopy* ☀️💧\n\n"
                  "Hey, your garden just grew a tiny bit from us talking. "
                  "Connection is nourishing, huh?",
              "*catches a raindrop on a leaf* 💧✨\n\n"
                  "Look at that — our chat sent some love to your garden~ "
                  "It's the little things!",
            ];
            final msg = rewardMessages[
            DateTime.now().millisecondsSinceEpoch % rewardMessages.length];

            setState(() {
              _messages.add(ChatMessage.ai(msg));
            });
            _conversationHistory.add({'role': 'model', 'text': msg});
            _scrollToBottom();
          }
        });

        debugPrint('🌸 Chat reward: +1 💧, +1 ☀️');
      }
    } catch (e) {
      debugPrint('⚠️ Chat reward failed (non-fatal): $e');
    }
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            const Text(_spiritEmoji, style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text(
              'Start fresh?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CuteTheme.deepGreen,
              ),
            ),
          ],
        ),
        content: Text(
          'Our conversation will fade like morning dew... '
              'but I\'ll still be here when you come back 💚',
          style: GoogleFonts.poppins(
            color: CuteTheme.textMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep chatting',
              style: GoogleFonts.poppins(color: CuteTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _messages.clear();
                _conversationHistory.clear();
                _meaningfulExchanges = 0;
                _rewardedThisSession = false;
                _lastFailedUserText = null;
                _addWelcomeMessage();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CuteTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Start fresh',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [CuteTheme.warmWhite, CuteTheme.cream],
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          if (_isOffline) _buildOfflineBanner(),
          Expanded(
            child: Stack(
              children: [
                _buildBackgroundDecorations(),
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: _messages.length +
                      (_isTyping ? 1 : 0) +
                      (_messages.length <= 2 ? 1 : 0),
                  itemBuilder: (context, index) {
                    final messageCount =
                        _messages.length + (_isTyping ? 1 : 0);
                    if (_messages.length <= 2 && index == messageCount) {
                      return _buildSuggestedPrompts();
                    }
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ],
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _ForestDecorationPainter(),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ListenableBuilder(
            listenable: _floatAnimation,
            builder: (context, _) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CuteTheme.primaryGreen.withValues(alpha: 0.2),
                        CuteTheme.petalPink.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: CuteTheme.primaryGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: CuteFernIcon(size: 32, isActive: true),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _spiritName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CuteTheme.deepGreen,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(_spiritEmoji, style: TextStyle(fontSize: 14)),
                  ],
                ),
                Text(
                  _isOffline
                      ? 'Resting in the forest...'
                      : _isTyping
                      ? 'Thinking... 💭'
                      : 'Your gentle forest companion',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _isOffline
                        ? CuteTheme.warmOrange
                        : _isTyping
                        ? CuteTheme.primaryGreen
                        : CuteTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CuteTheme.cream,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: CuteTheme.textMuted,
                size: 20,
              ),
              onPressed: _clearChat,
              tooltip: 'Start fresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CuteTheme.warmOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CuteTheme.warmOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$_spiritName is taking a forest nap... check your connection~',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: CuteTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── IMPROVED: Message bubble with retry button for failed messages ───
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final isFailed = message.status == MessageStatus.failed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: CuteTheme.petalPink.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CuteFernIcon(size: 20, isActive: true),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isUser ? CuteTheme.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(isUser ? 22 : 6),
                      bottomRight: Radius.circular(isUser ? 6 : 22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isUser
                            ? CuteTheme.primaryGreen
                            : CuteTheme.lavender)
                            .withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: isUser
                        ? null
                        : Border.all(
                      color: isFailed
                          ? CuteTheme.warmOrange.withValues(alpha: 0.4)
                          : CuteTheme.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: isUser ? Colors.white : CuteTheme.textDark,
                    ),
                  ),
                ),
              ),
              if (isUser) const SizedBox(width: 40),
            ],
          ),

          // ── Retry button for failed AI messages ──
          if (isFailed && !isUser)
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _messages.remove(message);
                  });
                  _sendMessage(isRetry: true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CuteTheme.warmOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CuteTheme.warmOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 14,
                        color: CuteTheme.warmOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Try again',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: CuteTheme.warmOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CuteTheme.petalPink.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CuteFernIcon(size: 20, isActive: true),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(22),
              ),
              border: Border.all(color: CuteTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: CuteTheme.lavender.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_spiritName is thinking',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: CuteTheme.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8),
                ListenableBuilder(
                  listenable: _typingController,
                  builder: (context, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return _buildTypingDot(index);
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    final offset = index * 0.2;
    final animValue = (_typingController.value + offset) % 1.0;
    final bounce = math.sin(animValue * math.pi * 2) * 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Transform.translate(
        offset: Offset(0, -bounce.abs()),
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompts() {
    final prompts = _getDynamicPrompts();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '✨ Or you could say...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: CuteTheme.textMuted,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: prompts.map((prompt) {
              return GestureDetector(
                onTap: () {
                  _messageController.text = prompt.$1;
                  _sendMessage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: CuteTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color:
                        CuteTheme.primaryGreen.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(prompt.$2,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          prompt.$1,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: CuteTheme.textGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── IMPROVED: More varied and context-aware prompts ───
  List<(String, String)> _getDynamicPrompts() {
    try {
      final moodCtrl = context.read<MoodController>();
      final habitCtrl = context.read<HabitController>();
      final gardenCtrl = context.read<GardenController>();

      final mood = moodCtrl.currentMood;
      final completedToday = habitCtrl.completedToday;
      final totalHabits = habitCtrl.totalHabits;
      final pendingHabits = habitCtrl.pendingHabits;
      final plantLevel = gardenCtrl.gardenState.plantLevel;
      final hour = DateTime.now().hour;

      final prompts = <(String, String)>[];

      // Time-based
      if (hour < 9) {
        prompts.add(('What\'s a good way to start today?', '🌅'));
      } else if (hour >= 21) {
        prompts.add(('Help me wind down', '🌙'));
      } else if (hour >= 14 && hour <= 16) {
        prompts.add(('I\'m hitting an afternoon slump', '😮‍💨'));
      }

      // Mood-based
      if (mood == 'anxious') {
        prompts.add(('Can we try a breathing exercise?', '🫧'));
      } else if (mood == 'stressed') {
        prompts.add(('Everything feels like too much', '😮‍💨'));
      } else if (mood == 'sad' || mood == 'lonely') {
        prompts.add(('I just need someone to talk to', '💙'));
      } else if (mood == 'angry') {
        prompts.add(('I need to vent about something', '🔥'));
      } else if (mood == 'happy') {
        prompts.add(('I\'m having a really good day!', '✨'));
      } else if (mood == 'tired') {
        prompts.add(('I\'m so tired today...', '😴'));
      } else if (mood == 'confused') {
        prompts.add(('I can\'t figure out how I feel', '🌀'));
      }

      // Habit-based
      if (completedToday > 0 &&
          completedToday == totalHabits &&
          totalHabits > 0) {
        prompts.add(('I finished everything today!', '🎉'));
      } else if (pendingHabits.isNotEmpty && completedToday > 0) {
        prompts.add(('What should I do next?', '🎯'));
      } else if (completedToday == 0 && totalHabits > 0 && hour > 12) {
        prompts.add(('I haven\'t started my habits yet...', '😅'));
      }

      // Garden-based
      if (plantLevel >= 8) {
        prompts.add(('Tell me about my garden', '🌳'));
      }

      // Always have a casual option
      prompts.add(('Just want to hang out~', '💬'));

      return prompts.take(4).toList();
    } catch (e) {
      return [
        ('How are you doing, Fern?', '🌿'),
        ('Just want to chat~', '💬'),
        ('Tell me something nice', '🌸'),
        ('I need a pick-me-up', '✨'),
      ];
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: CuteTheme.cream,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: CuteTheme.borderLight),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Talk to $_spiritName...',
                  hintStyle: GoogleFonts.poppins(
                    color: CuteTheme.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(
                  color: CuteTheme.textDark,
                  fontSize: 14,
                ),
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _sendMessage(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    CuteTheme.primaryGreen,
                    CuteTheme.leafGreen,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                    CuteTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForestDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = CuteTheme.primaryGreen.withValues(alpha: 0.03);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      40,
      paint,
    );

    paint.color = CuteTheme.petalPink.withValues(alpha: 0.04);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.3),
      35,
      paint,
    );

    paint.color = CuteTheme.lavender.withValues(alpha: 0.03);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.7),
      45,
      paint,
    );

    paint.color = CuteTheme.primaryGreen.withValues(alpha: 0.02);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.8),
      50,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}