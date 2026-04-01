// screens/kindness_chain_screen.dart
// Kindness Chain Screen - Cute Soft Version
// Using shared widget library

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/kindness_controller.dart';
import '../controllers/garden_controller.dart';
import '../controllers/mood_controller.dart'; // ✅ NEW: For mood-aware prompts
import '../models/kindness_chain_model.dart';
import '../utils/theme.dart';
import '../widgets/cute_garden_icons.dart';
import '../widgets/cute_widgets.dart';

class KindnessChainScreen extends StatefulWidget {
  const KindnessChainScreen({Key? key}) : super(key: key);

  @override
  State<KindnessChainScreen> createState() => _KindnessChainScreenState();
}

class _KindnessChainScreenState extends State<KindnessChainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ✅ NEW: Get current mood from MoodController (safe, returns null if unavailable)
  String? _getCurrentMood() {
    try {
      return Provider.of<MoodController>(context, listen: false).currentMood;
    } catch (e) {
      return null;
    }
  }

  /// ✅ NEW: Check and show streak milestone celebration
  void _checkStreakMilestone(KindnessController controller) {
    final milestone = controller.consumeMilestone();
    if (milestone == null) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 48,
                ),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CuteTheme.sunnyYellow.withValues(alpha: 0.9),
                        Colors.white,
                        CuteTheme.petalPink.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: CuteTheme.warningColor.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: const Text('🎉', style: TextStyle(fontSize: 56)),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$milestone Day Streak!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: CuteTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        KindnessController.getMilestoneMessage(milestone),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: CuteTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Keep spreading love~ 💝',
                          style: TextStyle(
                            fontSize: 15,
                            color: CuteTheme.flowerCenter,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ FIXED: Added _dismissed flag to prevent double-pop race condition
  void _showKindnessAddedFeedback(Map<String, dynamic>? rewardInfo) {
    final sunlight = rewardInfo?['sunlight'] ?? 2;
    final water = rewardInfo?['water'] ?? 1;
    final message = rewardInfo?['message'] ?? 'Kindness blooms in your garden~';

    bool dismissed = false;
    void safeDismiss() {
      if (dismissed) return;
      dismissed = true;
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false, // ✅ FIXED: was true, now managed by safeDismiss
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: safeDismiss, // ✅ Tap anywhere to dismiss safely
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: anim1,
                  curve: Curves.elasticOut,
                ),
                child: GestureDetector(
                  onTap: () {}, // Prevent tap-through to outer GestureDetector
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 48,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            CuteTheme.petalPink.withValues(alpha: 0.95),
                            Colors.white,
                            CuteTheme.lavender.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: CuteTheme.flowerCenter.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        CuteTheme.coralPink.withValues(alpha: 0.3),
                                        CuteTheme.petalPink.withValues(alpha: 0.3),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('💝', style: TextStyle(fontSize: 40)),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Kindness Blooms~',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: CuteTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: CuteTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // ✅ FIXED: Use FittedBox to prevent right overflow on small screens
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: CuteTheme.mintGreen.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: CuteTheme.mintGreen.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRewardBadgeWithIcon(const CuteWaterDrop(size: 24), '+$water', 'Water'),
                                  const SizedBox(width: 20),
                                  _buildRewardBadgeWithIcon(const CuteSunlight(size: 24), '+$sunlight', 'Sunlight'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your garden thanks you~',
                            style: TextStyle(
                              fontSize: 12,
                              color: CuteTheme.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 3), () {
      safeDismiss(); // ✅ FIXED: uses safeDismiss instead of raw Navigator.pop
    });
  }

  Widget _buildRewardBadgeWithIcon(Widget icon, String amount, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: CuteTheme.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: CuteTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showAddKindnessDialog() {
    final descController = TextEditingController();
    String selectedCategory = 'other';
    bool isPublic = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [CuteTheme.petalPink.withValues(alpha: 0.3), Colors.white],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: CuteTheme.flowerCenter.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CuteTheme.coralPink.withValues(alpha: 0.3),
                            CuteTheme.petalPink.withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: CuteTheme.coralPink.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text('💝', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share Your Kindness',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: CuteTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Every ripple matters~ 🌊',
                            style: TextStyle(
                              fontSize: 13,
                              color: CuteTheme.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CuteTheme.sunnyYellow.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: CuteTheme.warningColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CuteTheme.warningColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('💡', style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          // ✅ NEW: Mood-aware prompt instead of static one
                          Provider.of<KindnessController>(context, listen: false)
                              .getMoodAwarePrompt(
                            _getCurrentMood(),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber[800],
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: CuteTheme.coralPink.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: descController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                    decoration: InputDecoration(
                      labelText: 'What kindness did you share?',
                      labelStyle: const TextStyle(color: CuteTheme.textHint),
                      hintText: 'e.g., Made tea for a tired friend~ 🍵',
                      hintStyle: TextStyle(color: CuteTheme.textHint.withValues(alpha: 0.7), fontSize: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: CuteTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: CuteTheme.coralPink, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(18),
                    ),
                  ),
                ),
                // ✅ NEW: Quick-add suggestion chips
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: KindnessController.getQuickSuggestions(selectedCategory)
                      .take(3)
                      .map((suggestion) {
                    return GestureDetector(
                      onTap: () {
                        descController.text = suggestion;
                        // Move cursor to end
                        descController.selection = TextSelection.fromPosition(
                          TextPosition(offset: suggestion.length),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: CuteTheme.petalPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CuteTheme.coralPink.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CuteTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Text('🏷️', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Text(
                      'Who received your kindness?',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: CuteTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: KindnessCategory.categories.entries.map((entry) {
                    final isSelected = selectedCategory == entry.key;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedCategory = entry.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              CuteTheme.coralPink.withValues(alpha: 0.3),
                              CuteTheme.petalPink.withValues(alpha: 0.2),
                            ],
                          )
                              : null,
                          color: isSelected ? null : CuteTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? CuteTheme.coralPink.withValues(alpha: 0.6)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: CuteTheme.coralPink.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                              : null,
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? CuteTheme.flowerCenter : CuteTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CuteTheme.lavender.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Text('🌍', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share with Community',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: CuteTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Inspire others (anonymously) +1 ☀️',
                              style: TextStyle(
                                fontSize: 12,
                                color: CuteTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.scale(
                        scale: 0.9,
                        child: Switch(
                          value: isPublic,
                          onChanged: (value) => setModalState(() => isPublic = value),
                          activeColor: CuteTheme.flowerCenter,
                          activeTrackColor: CuteTheme.coralPink.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: const BorderSide(color: CuteTheme.borderLight),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: CuteTheme.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Consumer<KindnessController>(
                        builder: (context, kindnessController, _) {
                          return ElevatedButton(
                            onPressed: kindnessController.isLoading
                                ? null
                                : () async {
                              if (descController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Text('✏️', style: TextStyle(fontSize: 16)),
                                        SizedBox(width: 8),
                                        Expanded(child: Text('Please describe your kindness~')),
                                      ],
                                    ),
                                    backgroundColor: CuteTheme.warningColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                );
                                return;
                              }

                              // ✅ FIXED: Capture all references BEFORE popping the bottom sheet.
                              // After Navigator.pop(context), this bottom sheet's `context` is
                              // disposed, so `context.mounted` will always be false — which was
                              // the root cause of rewards/feedback never executing.
                              final authController =
                              Provider.of<AuthController>(context, listen: false);
                              final gardenController =
                              Provider.of<GardenController>(context, listen: false);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                              final description = descController.text.trim();
                              final category = selectedCategory;
                              final publicFlag = isPublic;

                              if (authController.currentUser == null) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: const Text('Please login first'),
                                    backgroundColor: CuteTheme.errorColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                );
                                return;
                              }

                              // ✅ FIXED (v3): 安全获取 uid，避免 ! 强制解包
                              final userId = authController.currentUser!.uid;

                              // Pop bottom sheet first for snappy feel
                              Navigator.pop(context);

                              try {
                                final success = await kindnessController.addKindnessAct(
                                  userId: userId,
                                  description: description,
                                  category: category,
                                  isPublic: publicFlag,
                                );

                                // ✅ FIXED: Use widget's `mounted` (State.mounted),
                                // NOT the bottom sheet's `context.mounted`
                                if (success && mounted) {
                                  // ✅ FIXED (v3): 仅在 onRewardEarned 未注入时手动发放，防止双倍奖励
                                  if (kindnessController.onRewardEarned == null) {
                                    final rewards = kindnessController.getLastRewardValues();
                                    await gardenController.addKindnessReward(
                                      sunlight: rewards['sunlight'] ?? 2,
                                      water: rewards['water'] ?? 1,
                                    );
                                  }

                                  if (mounted) {
                                    _showKindnessAddedFeedback(kindnessController.lastRewardInfo);

                                    // ✅ NEW: Check for streak milestone after a short delay
                                    Future.delayed(const Duration(seconds: 4), () {
                                      if (mounted) {
                                        _checkStreakMilestone(kindnessController);
                                      }
                                    });
                                  }
                                } else if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(kindnessController.errorMessage ?? 'Something went wrong...'),
                                      backgroundColor: CuteTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('Error adding kindness: $e');
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: CuteTheme.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CuteTheme.flowerCenter,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 4,
                              shadowColor: CuteTheme.coralPink.withValues(alpha: 0.4),
                            ),
                            child: kindnessController.isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('💝', style: TextStyle(fontSize: 18)),
                                SizedBox(width: 10),
                                Text(
                                  'Plant This Kindness',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KindnessController>(
      builder: (context, kindnessController, _) {
        return Column(
          children: [
            _buildStatsCard(kindnessController),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: CuteTheme.coralPink.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CuteTheme.coralPink.withValues(alpha: 0.8),
                      CuteTheme.flowerCenter.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: CuteTheme.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('💚', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text('My Garden'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🌍', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 6),
                        Text('Community'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ✅ FIXED: Use Stack so the floating button overlays the content
            // instead of competing for Column space (which caused the 54px overflow)
            Expanded(
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMyKindnessTab(kindnessController),
                      _buildCommunityTab(kindnessController),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildFloatingButtonArea(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(KindnessController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CuteTheme.petalPink.withValues(alpha: 0.6),
            Colors.white,
            CuteTheme.lavender.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.coralPink.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('💝', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kindness Garden',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CuteTheme.textPrimary,
                      ),
                    ),
                    Text(
                      controller.getEncouragementMessage(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: CuteTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  emoji: '💝',
                  value: controller.totalKindnessCount.toString(),
                  label: 'Total',
                  color: CuteTheme.flowerCenter,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: CuteTheme.borderLight,
                ),
                _buildStatItem(
                  emoji: '🌸',
                  value: controller.weeklyKindnessCount.toString(),
                  label: 'This Week',
                  color: CuteTheme.coralPink,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: CuteTheme.borderLight,
                ),
                _buildStatItem(
                  emoji: '🔥',
                  value: '${controller.currentStreak}',
                  label: 'Day Streak',
                  color: CuteTheme.warmOrange,
                ),
              ],
            ),
          ),
          // ✅ NEW: Category distribution visual
          if (controller.totalKindnessCount > 0) ...[
            const SizedBox(height: 16),
            _buildCategoryDistribution(controller),
          ],
        ],
      ),
    );
  }

  /// ✅ NEW: Visual category distribution bar
  Widget _buildCategoryDistribution(KindnessController controller) {
    final dist = controller.getCategoryDistribution();
    if (dist.isEmpty) return const SizedBox.shrink();

    final total = dist.values.fold(0, (sum, v) => sum + v);
    final categoryColors = <String, Color>{
      'self': CuteTheme.primaryGreen,
      'family': CuteTheme.warmOrange,
      'friends': CuteTheme.infoColor,
      'stranger': CuteTheme.flowerCenter,
      'nature': const Color(0xFF81C784),
      'community': CuteTheme.lavender,
      'other': CuteTheme.textHint,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where your kindness goes~',
            style: TextStyle(
              fontSize: 12,
              color: CuteTheme.textHint,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // Distribution bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: dist.entries.map((entry) {
                  final fraction = entry.value / total;
                  return Expanded(
                    flex: (fraction * 100).round().clamp(1, 100),
                    child: Container(
                      color: categoryColors[entry.key] ?? CuteTheme.textHint,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: dist.entries.map((entry) {
              final color = categoryColors[entry.key] ?? CuteTheme.textHint;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${KindnessCategory.getLabel(entry.key)} ${entry.value}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: CuteTheme.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: CuteTheme.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildMyKindnessTab(KindnessController controller) {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🌸', style: TextStyle(fontSize: 40)),
            SizedBox(height: 16),
            Text(
              'Loading your kindness...',
              style: TextStyle(color: CuteTheme.textHint),
            ),
          ],
        ),
      );
    }

    if (controller.myKindnessActs.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: controller.myKindnessActs.length,
      itemBuilder: (context, index) {
        final act = controller.myKindnessActs[index];
        return _buildKindnessCard(act, isOwn: true, controller: controller);
      },
    );
  }

  Widget _buildEmptyState() {
    // ✅ FIXED: Removed actionText/onAction — the floating "Plant Kindness"
    // button at the bottom already serves this purpose. Having both caused
    // the 54px overflow and visual overlap on tab switch.
    // Wrapped in SingleChildScrollView to prevent overflow on small screens.
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80), // space for floating button
        child: CuteEmptyState(
          emoji: '🌱',
          title: 'Your kindness garden awaits~',
          subtitle: 'Plant your first seed of kindness\nand watch it bloom 🌸',
          gradientColors: [CuteTheme.petalPink, CuteTheme.lavender],
        ),
      ),
    );
  }

  Widget _buildCommunityTab(KindnessController controller) {
    if (controller.communityKindnessActs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: CuteTheme.lavender.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌍', style: TextStyle(fontSize: 45)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Community garden is quiet~',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: CuteTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Be the first to share publicly\nand inspire others! 🌟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: CuteTheme.textHint,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: controller.communityKindnessActs.length,
      itemBuilder: (context, index) {
        final act = controller.communityKindnessActs[index];
        return _buildKindnessCard(act, isOwn: false, controller: controller);
      },
    );
  }

  Widget _buildKindnessCard(KindnessAct act, {required bool isOwn, required KindnessController controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.coralPink.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [CuteTheme.coralPink, CuteTheme.petalPink, CuteTheme.sunnyYellow],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // ✅ FIXED: Use fixed-size SizedBox to prevent ZWJ emoji
                      // (like 👨‍👩‍👧) from expanding the container and causing right overflow
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CuteTheme.coralPink.withValues(alpha: 0.2),
                                CuteTheme.petalPink.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              KindnessCategory.getEmoji(act.category),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              KindnessCategory.getLabel(act.category),
                              style: const TextStyle(
                                fontSize: 14,
                                color: CuteTheme.flowerCenter,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(act.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: CuteTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isOwn)
                        IconButton(
                          icon: const Icon(Icons.more_horiz, color: CuteTheme.textHint),
                          onPressed: () => _showDeleteDialog(act, controller),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CuteTheme.petalPink.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      act.description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: CuteTheme.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  if (!isOwn) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        if (act.rippleCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: CuteTheme.skyBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🌊', style: TextStyle(fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(
                                  '${act.rippleCount} ripples',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CuteTheme.infoColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            // ✅ FIX: Pass current user ID to prevent self-rippling
                            final currentUserId = Provider.of<AuthController>(
                              context, listen: false,
                            ).currentUser?.uid;

                            final success = await controller.rippleKindness(
                              act.id,
                              currentUserId: currentUserId,
                            );

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Text(
                                        success ? '🌊' : '💚',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          success
                                              ? 'Kindness rippled forward~'
                                              : 'Your own kindness already shines~',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: success
                                      ? CuteTheme.infoColor
                                      : CuteTheme.warningColor,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  CuteTheme.skyBlue.withValues(alpha: 0.15),
                                  CuteTheme.infoColor.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: CuteTheme.skyBlue.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🌊', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 6),
                                Text(
                                  'Pass it on~',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CuteTheme.infoColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButtonArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: CuteTheme.flowerCenter.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _showAddKindnessDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: CuteTheme.flowerCenter,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌱', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                'Plant Kindness',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(KindnessAct act, KindnessController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CuteTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🥀', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text(
              'Remove this?',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'This kindness will be removed from your garden...',
          style: TextStyle(color: CuteTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep it 💚',
              style: TextStyle(color: CuteTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await controller.deleteKindnessAct(act.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CuteTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now ✨';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays == 0) {
      return 'Today ${DateFormat('HH:mm').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday 💫';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}