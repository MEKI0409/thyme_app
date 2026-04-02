// screens/habit_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/habit_controller.dart';
import '../controllers/mood_controller.dart';
import '../controllers/garden_controller.dart';
import '../models/habit_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/cute_garden_icons.dart';
import '../widgets/cute_widgets.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({Key? key}) : super(key: key);

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen>
    with TickerProviderStateMixin {
  final Map<String, _RewardAnimation> _activeRewards = {};

  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'Self-Care';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: CuteTheme.cardBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(CuteTheme.radiusXLarge),
            topRight: Radius.circular(CuteTheme.radiusXLarge),
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CuteTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CuteTheme.primaryGreen.withValues(alpha: 0.15),
                          CuteTheme.petalPink.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('🌱', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant a New Habit',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: CuteTheme.deepGreen,
                        ),
                      ),
                      Text(
                        'Small steps, meaningful growth',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: CuteTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _buildInputField(
                controller: titleController,
                label: 'Habit Name',
                hint: 'e.g., 5-minute breathing',
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: descController,
                label: 'Why does this matter to you?',
                hint: 'Optional, but helps with motivation',
                icon: Icons.favorite_outline,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: CuteTheme.cream,
                      borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
                      border: Border.all(color: CuteTheme.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.expand_more, color: CuteTheme.textMuted),
                        items: Constants.habitCategories.keys.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                CuteCategoryIcon(category: category, size: 24),
                                const SizedBox(width: 12),
                                Text(category, style: GoogleFonts.poppins()),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setLocalState(() => selectedCategory = value!);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
                        ),
                        side: const BorderSide(color: CuteTheme.borderLight),
                      ),
                      child: Text(
                        'Maybe Later',
                        style: GoogleFonts.poppins(color: CuteTheme.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty) {
                          final authController =
                          Provider.of<AuthController>(context, listen: false);
                          final user = authController.currentUser;
                          if (user == null) return;
                          final habitController =
                          Provider.of<HabitController>(context, listen: false);
                          await habitController.createHabit(
                            userId: user.uid,
                            title: titleController.text,
                            description: descController.text,
                            category: selectedCategory,
                          );
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CuteTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Plant Habit',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('🌱', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: CuteTheme.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: CuteTheme.textMuted),
        hintStyle: GoogleFonts.poppins(color: CuteTheme.textMuted.withValues(alpha: 0.6)),
        prefixIcon: Icon(icon, color: CuteTheme.primaryGreen, size: 22),
        filled: true,
        fillColor: CuteTheme.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
          borderSide: const BorderSide(color: CuteTheme.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
          borderSide: const BorderSide(color: CuteTheme.primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  List<Habit> _getRecommendedHabits(String? currentMood, List<Habit> allHabits) {
    if (currentMood == null) return [];

    final recommendedCategories = Constants.moodToCategories[currentMood] ?? [];

    return allHabits
        .where((habit) =>
    recommendedCategories.contains(habit.category) &&
        !habit.isCompletedToday())
        .take(3)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<HabitController, MoodController, GardenController>(
      builder: (context, habitController, moodController, gardenController, _) {
        if (habitController.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌱', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Tending to your habits...',
                  style: GoogleFonts.poppins(
                    color: CuteTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        final habits = habitController.habits;
        final currentMood = moodController.currentMood;
        final recommendedHabits = _getRecommendedHabits(currentMood, habits);
        final hasHabits = habits.isNotEmpty;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(habitController, gardenController),
                  const SizedBox(height: 24),
                  if (recommendedHabits.isNotEmpty && currentMood != null) ...[
                    _buildRecommendationsSection(
                        recommendedHabits, currentMood, habitController, gardenController),
                    const SizedBox(height: 24),
                  ],
                  _buildHabitsHeader(),
                  const SizedBox(height: 12),
                  if (!hasHabits)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        return _buildHabitCard(
                            habits[index], habitController, gardenController, moodController);
                      },
                    ),
                  if (hasHabits) const SizedBox(height: 80),
                ],
              ),
            ),
            if (hasHabits)
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: _showAddHabitDialog,
                  backgroundColor: CuteTheme.primaryGreen,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'New Habit',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProgressCard(HabitController controller, GardenController gardenController) {
    final progress = controller.completionRate;
    final garden = gardenController.gardenState;

    return CuteGradientCard(
      colors: [CuteTheme.cardBg, CuteTheme.primaryGreen.withValues(alpha: 0.08)],
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResourceBadgeWithIcon(const CuteWaterDrop(size: 24), garden.waterDrops, 'Water', CuteTheme.waterBlue),
              _buildStatItem('Total', controller.totalHabits.toString(), Icons.eco_outlined),
              _buildResourceBadgeWithIcon(const CuteSunlight(size: 24), garden.sunlightPoints, 'Sunlight', CuteTheme.warmOrange),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Progress",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CuteTheme.textGreen,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: CuteTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CuteProgressBar(
                progress: progress,
                height: 10,
                borderRadius: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceBadgeWithIcon(Widget icon, int value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: CuteTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: CuteTheme.primaryGreen, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: CuteTheme.deepGreen,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: CuteTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CuteTheme.primaryGreen.withValues(alpha: 0.15),
                CuteTheme.petalPink.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('🌿', style: TextStyle(fontSize: 20)),
        ),
        const SizedBox(width: 12),
        Text(
          'Your Habits',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: CuteTheme.deepGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return CuteEmptyState(
      emoji: '🌱',
      title: 'Plant your first habit',
      subtitle: 'Small seeds grow into beautiful gardens',
      actionText: 'Plant a Habit',
      onAction: _showAddHabitDialog,
    );
  }

  Widget _buildRecommendationsSection(
      List<Habit> recommendedHabits,
      String currentMood,
      HabitController habitController,
      GardenController gardenController,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CuteTheme.lavender.withValues(alpha: 0.2),
            CuteTheme.petalPink.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(CuteTheme.radiusLarge),
        border: Border.all(color: CuteTheme.lavender.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: CuteTheme.textGreen,
                    ),
                    children: [
                      const TextSpan(text: 'Feeling '),
                      TextSpan(
                        text: currentMood,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Constants.getMoodColor(currentMood),
                        ),
                      ),
                      const TextSpan(text: '? Try these:'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recommendedHabits.map((habit) {
              return GestureDetector(
                onTap: () => _completeHabit(habit, habitController, gardenController),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: CuteTheme.cardBg,
                    borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: CuteTheme.lavender.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CuteCategoryIcon(category: habit.category, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        habit.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: CuteTheme.textDark,
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

  Widget _buildHabitCard(
      Habit habit,
      HabitController habitController,
      GardenController gardenController,
      MoodController moodController,
      ) {
    final isCompleted = habit.isCompletedToday();
    final isRewarded = habit.isRewardedToday();
    final showReward = _activeRewards.containsKey(habit.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: CuteTheme.cardBg,
        borderRadius: BorderRadius.circular(CuteTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? CuteTheme.leafGreen.withValues(alpha: 0.15)
                : CuteTheme.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: isCompleted
            ? Border.all(color: CuteTheme.leafGreen.withValues(alpha: 0.4), width: 2)
            : Border.all(color: CuteTheme.borderLight.withValues(alpha: 0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(CuteTheme.radiusLarge),
          onTap: isCompleted ? null : () => _completeHabit(habit, habitController, gardenController),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? CuteTheme.leafGreen.withValues(alpha: 0.15)
                            : CuteTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: CuteTheme.leafGreen, size: 28)
                            : CuteCategoryIcon(category: habit.category, size: 28),
                      ),
                    ),
                    if (showReward)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: _buildMiniRewardBadge(_activeRewards[habit.id]!),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? CuteTheme.textMuted : CuteTheme.deepGreen,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            habit.category,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: CuteTheme.textMuted,
                            ),
                          ),
                          if (habit.currentStreak > 0) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: CuteTheme.warmOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${habit.currentStreak} days',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: CuteTheme.warmOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (isRewarded && !isCompleted) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CuteTheme.borderLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Rewarded',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: CuteTheme.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CuteTheme.primaryGreen, CuteTheme.leafGreen],
                      ),
                      borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
                      boxShadow: [
                        BoxShadow(
                          color: CuteTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                      isRewarded ? 'Redo' : 'Complete',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showUncompleteDialog(habit, habitController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: CuteTheme.leafGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check, color: CuteTheme.leafGreen, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Done',
                            style: GoogleFonts.poppins(
                              color: CuteTheme.leafGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.close, color: CuteTheme.textMuted, size: 14),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUncompleteDialog(Habit habit, HabitController habitController) {
    final isRewarded = habit.isRewardedToday();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CuteTheme.warmOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('↩️', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Text(
              'Undo Completion?',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CuteTheme.deepGreen,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark "${habit.title}" as not completed?',
              style: GoogleFonts.poppins(color: CuteTheme.textGreen),
            ),
            if (isRewarded) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CuteTheme.sunnyYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: CuteTheme.sunnyYellow.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Text('⚠️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You already received today\'s reward. Completing again won\'t give extra rewards.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: CuteTheme.warmOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep',
              style: GoogleFonts.poppins(color: CuteTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await habitController.uncompleteHabit(habit);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('↩️', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 10),
                        Text('${habit.title} marked as not done'),
                      ],
                    ),
                    backgroundColor: CuteTheme.warmOrange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CuteTheme.warmOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
              ),
            ),
            child: Text(
              'Undo',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRewardBadge(_RewardAnimation reward) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -30 * value),
          child: Opacity(
            opacity: (1 - value).clamp(0.0, 1.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: CuteTheme.cardBg,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: CuteTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+${reward.water}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CuteTheme.waterBlue,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const CuteWaterDrop(size: 14),
                  const SizedBox(width: 6),
                  Text(
                    '+${reward.sunlight}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CuteTheme.warmOrange,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const CuteSunlight(size: 14),
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _activeRewards.remove(reward.habitId);
            });
          }
        });
      },
    );
  }

  Future<void> _completeHabit(
      Habit habit,
      HabitController habitController,
      GardenController gardenController,
      ) async {
    if (habit.isCompletedToday()) return;

    final moodController = Provider.of<MoodController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    if (user == null) return;
    final userId = user.uid;

    final result = await habitController.completeHabit(habit);

    if (result['success'] != true) return;

    final shouldReward = result['shouldReward'] == true;

    int waterReward = 0;
    int sunlightReward = 0;

    if (shouldReward) {
      final rewards = await gardenController.rewardHabitCompletion(
        userId: userId,
        habit: habit,
        currentMood: moodController.currentMood,
      );
      waterReward = rewards['water'] ?? 1;
      sunlightReward = rewards['sunlight'] ?? 1;

      if (mounted) {
        setState(() {
          _activeRewards[habit.id] = _RewardAnimation(
            habitId: habit.id,
            water: waterReward,
            sunlight: sunlightReward,
          );
        });
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  shouldReward
                      ? '${habit.title} completed! +$waterReward💧 +$sunlightReward☀️'
                      : '${habit.title} completed! (No reward - already claimed today)',
                ),
              ),
            ],
          ),
          backgroundColor: shouldReward ? CuteTheme.leafGreen : CuteTheme.textMuted,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CuteTheme.radiusSmall),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _RewardAnimation {
  final String habitId;
  final int water;
  final int sunlight;

  _RewardAnimation({
    required this.habitId,
    required this.water,
    required this.sunlight,
  });
}