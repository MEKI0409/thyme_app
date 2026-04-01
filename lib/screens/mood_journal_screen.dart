// screens/mood_journal_screen.dart
// Thyme App Mood Journal Page - Cute Style Version 🌸
// Using shared widget library

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/mood_controller.dart';
import '../controllers/garden_controller.dart';
import '../services/journal_prompts_service.dart';
import '../widgets/reward_animation_widget.dart';
import '../widgets/cute_garden_icons.dart';
import '../widgets/cute_widgets.dart';
import '../utils/theme.dart';
import '../utils/date_utils.dart';
import '../utils/constants.dart'; // ✅ ADDED: for unified getMoodColor

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({Key? key}) : super(key: key);

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen>
    with SingleTickerProviderStateMixin {
  final _journalController = TextEditingController();
  bool _isAnalyzing = false;
  String? _currentPrompt;

  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _currentPrompt = JournalPromptsService.getRandomPrompt();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _journalController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  String _getJournalRewardMessage(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious':
        return 'Thank you for sharing. That takes courage. 💜';
      case 'sad':
        return 'Your feelings are valid. Thank you for expressing them. 💙';
      case 'stressed':
        return 'Acknowledging stress is the first step. 🌿';
      case 'happy':
        return 'What a lovely moment to capture. 🌸';
      case 'calm':
        return 'A peaceful reflection. Thank you. 🍃';
      default:
        return 'Your words matter. Thank you for checking in. 💚';
    }
  }

  Map<String, int> _calculateJournalRewards(String mood) {
    int water = 1;
    int sunlight = 1;

    if (mood == 'anxious' || mood == 'sad' || mood == 'stressed') {
      water += 1;
    }

    if (_journalController.text.length > 100) {
      sunlight += 1;
    }

    return {'water': water, 'sunlight': sunlight};
  }

  Future<void> _submitJournal() async {
    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🌱', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Text(
                'Take your time. Write when ready.',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: CuteTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
          ),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    final authController = Provider.of<AuthController>(context, listen: false);
    final moodController = Provider.of<MoodController>(context, listen: false);
    final gardenController = Provider.of<GardenController>(context, listen: false);

    final entry = await moodController.createMoodEntry(
      userId: authController.currentUser!.uid,
      journalText: _journalController.text.trim(),
    );

    if (entry != null) {
      await gardenController.addJournalReward(
        entry.detectedMood,
        entry.sentimentScore,
      );
    }

    setState(() => _isAnalyzing = false);

    if (entry != null && mounted) {
      final rewards = _calculateJournalRewards(entry.detectedMood);
      _journalController.clear();
      setState(() => _currentPrompt = JournalPromptsService.getRandomPrompt());

      RewardCelebration.show(
        context,
        waterDrops: rewards['water']!,
        sunlightPoints: rewards['sunlight']!,
        message: _getJournalRewardMessage(entry.detectedMood),
        onComplete: () => _showMoodDetectedDialog(entry),
      );
    }
  }

  void _showMoodDetectedDialog(entry) {
    final moodColor = _getMoodColor(entry.detectedMood);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
        ),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    moodColor.withValues(alpha: 0.2),
                    moodColor.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: moodColor.withValues(alpha: 0.2),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CuteMoodEmoji(
                mood: entry.detectedMood,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You seem to be feeling',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CuteTheme.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              entry.detectedMood.toUpperCase(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: moodColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CuteTheme.cream,
                borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
                border: Border.all(color: CuteTheme.borderLight),
              ),
              child: Text(
                _getMoodValidation(entry.detectedMood),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: CuteTheme.textGreen,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16, color: CuteTheme.sunnyYellow),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Check Habits tab for gentle suggestions',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: CuteTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: moodColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
                ),
                elevation: 0,
              ),
              child: Text(
                'Thank you 🌸',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: _getMoodEmoji removed (dead code, UI uses CuteMoodEmoji widget)

  // ✅ FIXED: Delegate to Constants for single source of truth
  Color _getMoodColor(String mood) {
    return Constants.getMoodColor(mood);
  }

  String _getMoodValidation(String mood) {
    switch (mood.toLowerCase()) {
      case 'anxious': return 'Anxiety is your mind trying to protect you. You\'re safe here. 💜';
      case 'sad': return 'Sadness is part of being human. Feel it, then let it pass. 💙';
      case 'stressed': return 'Take a deep breath. This moment will pass. 🌿';
      case 'happy': return 'What a beautiful feeling to hold onto. Cherish it. 🌸';
      case 'calm': return 'Peace suits you. May it stay with you. 🍃';
      default: return 'Every feeling is a visitor. Welcome them all. 💚';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodController>(
      builder: (context, moodController, _) {
        final entries = moodController.moodEntries;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Journal input area
              ListenableBuilder(
                listenable: _breathingAnimation,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CuteTheme.cardBg,
                        borderRadius: BorderRadius.circular(CuteTheme.radiusLarge),
                        boxShadow: CuteTheme.softShadow,
                        border: Border.all(
                          color: CuteTheme.borderLight.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildJournalHeader(),
                          if (_currentPrompt != null) _buildPromptCard(),
                          _buildTextInput(),
                          _buildRewardsHint(),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // History title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CuteTheme.lavender.withValues(alpha: 0.3),
                          CuteTheme.petalPink.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('📖', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Entries',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: CuteTheme.deepGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // History list
              if (entries.isEmpty)
                _buildEmptyEntriesState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    return _buildMoodEntryCard(entries[index]);
                  },
                ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJournalHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CuteTheme.primaryGreen.withValues(alpha: 0.08),
            CuteTheme.petalPink.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(CuteTheme.radiusLarge),
          topRight: Radius.circular(CuteTheme.radiusLarge),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CuteTheme.cardBg,
              borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: CuteTheme.primaryGreen.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Text('✍️', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CuteTheme.deepGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No judgment. Just expression.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: CuteTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CuteTheme.petalPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => setState(() => _currentPrompt = JournalPromptsService.getRandomPrompt()),
              icon: const Icon(
                Icons.refresh_rounded,
                color: CuteTheme.flowerCenter,
                size: 20,
              ),
              tooltip: 'New prompt',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CuteTheme.sunnyYellow.withValues(alpha: 0.15),
            CuteTheme.warmOrange.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
        border: Border.all(color: CuteTheme.sunnyYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: CuteTheme.warmOrange,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentPrompt!,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: CuteTheme.textGreen,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: _journalController,
        decoration: InputDecoration(
          hintText: 'Write whatever comes to mind...',
          hintStyle: GoogleFonts.poppins(
            color: CuteTheme.textMuted.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: GoogleFonts.poppins(
          fontSize: 15,
          height: 1.7,
          color: CuteTheme.textDark,
        ),
        maxLines: 6,
        minLines: 4,
        enabled: !_isAnalyzing,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isAnalyzing ? null : _submitJournal,
          style: ElevatedButton.styleFrom(
            backgroundColor: CuteTheme.primaryGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
            ),
            elevation: 0,
          ),
          child: _isAnalyzing
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Listening...',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.spa_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                'Share with Garden',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              const Text('🌱', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your garden will receive ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: CuteTheme.textMuted,
            ),
          ),
          const Text('💧', style: TextStyle(fontSize: 12)),
          Text(
            ' + ',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: CuteTheme.textMuted,
            ),
          ),
          const Text('☀️', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildEmptyEntriesState() {
    // Using CuteEmptyState widget
    return CuteEmptyState(
      emoji: '📝',
      title: 'Your journal awaits',
      subtitle: 'Start writing to see your journey unfold.\nAll feelings are welcome here.',
      gradientColors: [
        CuteTheme.lavender.withValues(alpha: 0.3),
        CuteTheme.petalPink.withValues(alpha: 0.2),
      ],
    );
  }

  Widget _buildMoodEntryCard(entry) {
    final moodColor = _getMoodColor(entry.detectedMood);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CuteTheme.cardBg,
        borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
        border: Border.all(color: CuteTheme.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: moodColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        moodColor.withValues(alpha: 0.2),
                        moodColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: moodColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CuteMoodEmoji(
                        mood: entry.detectedMood,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.detectedMood,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: moodColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(entry.createdAt),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: CuteTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.journalText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CuteTheme.textGreen,
                height: 1.6,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Using ThymeDateUtils
  String _formatTimestamp(DateTime time) {
    return ThymeDateUtils.formatRelative(time);
  }
}