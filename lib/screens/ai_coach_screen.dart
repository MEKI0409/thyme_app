// screens/ai_coach_screen.dart
// Forest Spirit Fern - Gentle AI Companion
// Using shared widget library

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // ✅ NEW: Access controllers
import '../services/gemini_service.dart';
import '../controllers/mood_controller.dart'; // ✅ NEW: Current mood
import '../controllers/habit_controller.dart'; // ✅ NEW: Habit data
import '../controllers/garden_controller.dart'; // ✅ NEW: Garden data + rewards
import '../controllers/auth_controller.dart'; // ✅ NEW: User ID for rewards
import '../models/chat_message_model.dart';
import '../utils/theme.dart';
import '../utils/date_utils.dart'; // ✅ NEW: Time-based greetings
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

  // ✅ NEW Priority 4: Chat reward tracking
  int _meaningfulExchanges = 0; // Count of user messages this session
  bool _rewardedThisSession = false; // Only reward once per session
  static const int _rewardThreshold = 3; // Messages needed before reward

  late AnimationController _typingController;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Spirit name and personality
  static const String _spiritName = 'Fern';
  static const String _spiritEmoji = '🌿';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _addWelcomeMessage();
    _checkServiceStatus();
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

  void _addWelcomeMessage() {
    // ✅ NEW: Context-aware welcome message
    String welcomeText;

    try {
      final moodController = context.read<MoodController>();
      final habitController = context.read<HabitController>();
      final currentMood = moodController.currentMood;
      final completedToday = habitController.completedToday;
      final greeting = ThymeDateUtils.getSimpleGreeting();

      if (currentMood == 'sad' || currentMood == 'anxious') {
        welcomeText = "$greeting~ 🍃\n\n"
            "I'm $_spiritName, your forest companion. "
            "I sense things might feel a bit heavy... "
            "I'm right here with you. No need to explain anything.";
      } else if (completedToday > 0) {
        welcomeText = "$greeting~ ✨\n\n"
            "I'm $_spiritName! I noticed you've already done $completedToday "
            "${completedToday == 1 ? 'habit' : 'habits'} today — "
            "your garden can feel it! How are you doing?";
      } else {
        welcomeText = "Hi there~ ✨\n\n"
            "I'm $_spiritName, a forest spirit who lives in your garden. "
            "I'm here to keep you company, not to judge or give advice.\n\n"
            "How are you feeling right now? 🍃";
      }
    } catch (e) {
      // Fallback if providers not available yet
      welcomeText = "Hi there~ ✨\n\n"
          "I'm $_spiritName, a forest spirit who lives in your garden. "
          "I'm here to keep you company, not to judge or give advice.\n\n"
          "How are you feeling right now? 🍃";
    }

    setState(() {
      _messages.add(ChatMessage.ai(welcomeText));
    });
  }

  Future<void> _sendMessage() async {
    // ✅ FIXED (v3): 防止并发发送导致消息乱序
    if (_isTyping) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    _focusNode.unfocus();

    final userMessage = ChatMessage.user(text);
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _meaningfulExchanges++; // ✅ NEW: Track exchanges for reward
    });

    _scrollToBottom();

    try {
      // ✅ NEW Priority 1: Gather context from controllers
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

      // ✅ NEW: Send message WITH context
      final response = await _geminiService.chatWithContext(
        text,
        currentMood: currentMood,
        habitsCompletedToday: habitsCompletedToday,
        totalHabits: totalHabits,
        plantLevel: plantLevel,
        longestStreak: longestStreak,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage.ai(response));
          _isTyping = false;
        });
        _scrollToBottom();

        // ✅ NEW Priority 4: Reward garden after meaningful exchanges
        _checkAndRewardChat();
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "*rustles leaves gently* 🍃\n\n"
                "I got a bit lost in the forest... but I'm still here with you. "
                "Want to try talking again?",
            isUser: false,
            timestamp: DateTime.now(),
            status: MessageStatus.sent,
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  /// ✅ NEW Priority 4: Reward garden for meaningful chat sessions
  void _checkAndRewardChat() {
    if (_rewardedThisSession) return;
    if (_meaningfulExchanges < _rewardThreshold) return;

    _rewardedThisSession = true;

    try {
      final authCtrl = context.read<AuthController>();
      final gardenCtrl = context.read<GardenController>();
      final user = authCtrl.currentUser;

      if (user != null) {
        gardenCtrl.addKindnessReward(sunlight: 1, water: 1);

        // Add a gentle reward message from Fern
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _messages.add(ChatMessage.ai(
                "*a tiny water drop and a sunbeam appear* 💧☀️\n\n"
                    "Our little chat just nourished your garden~ "
                    "Thank you for spending time here with me!",
              ));
            });
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
      builder: (context) => AlertDialog(
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
          'Our conversation will fade like morning dew... but I\'ll still remember you 💚',
          style: GoogleFonts.poppins(
            color: CuteTheme.textMuted,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep chatting',
              style: GoogleFonts.poppins(color: CuteTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _meaningfulExchanges = 0; // ✅ NEW: Reset reward tracking
                _rewardedThisSession = false;
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
          colors: [
            CuteTheme.warmWhite,
            CuteTheme.cream,
          ],
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessageBubble(_messages[index]);
                  },
                ),
              ],
            ),
          ),
          if (_messages.length <= 2) _buildSuggestedPrompts(),
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
      child: SafeArea(
        bottom: false,
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
                        : 'Your gentle forest companion',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _isOffline
                          ? CuteTheme.warmOrange
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
              '$_spiritName is taking a forest nap... but still here in spirit~',
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? CuteTheme.primaryGreen
                    : Colors.white,
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
                  color: CuteTheme.borderLight,
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
    // ✅ NEW Priority 2: Dynamic suggestion chips based on context
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
                        color: CuteTheme.primaryGreen.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(prompt.$2, style: const TextStyle(fontSize: 14)),
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

  /// ✅ NEW Priority 2: Generate context-aware suggestion prompts
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

      // Time-based prompt
      if (hour < 12) {
        prompts.add(('How should I start my day?', '🌅'));
      } else if (hour >= 21) {
        prompts.add(('Help me wind down for tonight', '🌙'));
      }

      // Mood-based prompts
      if (mood == 'anxious' || mood == 'stressed') {
        prompts.add(('Can we do a breathing exercise?', '🫁'));
        prompts.add(('Everything feels overwhelming', '😰'));
      } else if (mood == 'sad') {
        prompts.add(('I just need someone to listen', '💙'));
        prompts.add(('Tell me something comforting', '🌸'));
      } else if (mood == 'happy') {
        prompts.add(('I\'m having a great day!', '✨'));
        prompts.add(('What should I try next?', '🚀'));
      }

      // Habit-based prompts
      if (completedToday > 0 && completedToday == totalHabits && totalHabits > 0) {
        prompts.add(('I finished all my habits today!', '🎉'));
      } else if (pendingHabits.isNotEmpty) {
        prompts.add(('What habit should I do next?', '🎯'));
      }

      // Garden-based prompt
      if (plantLevel >= 5) {
        prompts.add(('How\'s my garden doing?', '🌿'));
      }

      // Always include a casual chat option
      prompts.add(('Just want to chat~', '💬'));

      // Return max 4 prompts
      return prompts.take(4).toList();
    } catch (e) {
      // Fallback to static prompts if controllers not available
      return [
        ('I\'m feeling a bit down today', '🥺'),
        ('Just want to chat~', '💬'),
        ('Tell me something comforting', '🌸'),
        ('I need a gentle hug', '🤗'),
      ];
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  hintText: 'Share your thoughts with $_spiritName...',
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
            onTap: _sendMessage,
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
                    color: CuteTheme.primaryGreen.withValues(alpha: 0.3),
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