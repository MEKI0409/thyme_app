// pages/notification_settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../models/settings_model.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _isPickingTime = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final notifications = controller.settings.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF5),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2D3B2D),
        centerTitle: true,
      ),
      body: controller.isLoading
          ? const Center(
        child:
        CircularProgressIndicator(color: Color(0xFF4DB6AC)),
      )
          : ListView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 24),

          _buildReminderCard(
            controller: controller,
            emoji: '🎯',
            title: 'Habit Reminders',
            description: 'A gentle nudge to complete your daily habits',
            isEnabled: notifications.habitRemindersEnabled,
            reminderTime: notifications.habitReminderTime,
            onToggle: (v) => controller.setHabitRemindersEnabled(v),
            onTimeTap: () => _pickTime(
              notifications.habitReminderTime,
              controller.setHabitReminderTime,
            ),
          ),
          const SizedBox(height: 12),

          _buildReminderCard(
            controller: controller,
            emoji: '📝',
            title: 'Journal Reminder',
            description: 'Remember to check in with your feelings',
            isEnabled: notifications.journalReminderEnabled,
            reminderTime: notifications.journalReminderTime,
            onToggle: (v) => controller.setJournalReminderEnabled(v),
            onTimeTap: () => _pickTime(
              notifications.journalReminderTime,
              controller.setJournalReminderTime,
            ),
          ),
          const SizedBox(height: 12),

          _buildReminderCard(
            controller: controller,
            emoji: '🌸',
            title: 'Kindness Reminder',
            description: 'A small prompt to spread some love',
            isEnabled: notifications.kindnessReminderEnabled,
            reminderTime: notifications.kindnessReminderTime,
            onToggle: (v) => controller.setKindnessReminderEnabled(v),
            onTimeTap: () => _pickTime(
              notifications.kindnessReminderTime,
              controller.setKindnessReminderTime,
            ),
          ),
          const SizedBox(height: 24),

          _buildSimpleToggleCard(
            emoji: '🔥',
            title: 'Streak Alerts',
            description: 'Get notified when your streak is about to break',
            isEnabled: notifications.streakAlertEnabled,
            onToggle: controller.isLoading
                ? null
                : (v) => controller.setStreakAlertEnabled(v),
          ),

          if (controller.errorMessage != null) ...[
            const SizedBox(height: 16),
            _buildErrorBanner(controller.errorMessage!),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFE0B2).withOpacity(0.5),
            const Color(0xFFFFF8E1).withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔔', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Set up gentle reminders to help you stay on track. We promise to be kind about it~ 💛',
              style: TextStyle(
                fontSize: 13,
                color: const Color(0xFF2D3B2D).withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required SettingsController controller,
    required String emoji,
    required String title,
    required String description,
    required bool isEnabled,
    required ReminderTime reminderTime,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题行 + 开关
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3B2D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF2D3B2D).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: controller.isLoading ? null : onToggle,
                activeColor: const Color(0xFF4DB6AC),
              ),
            ],
          ),

          if (isEnabled) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F4F0)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _isPickingTime ? null : onTimeTap,
              child: AnimatedOpacity(
                opacity: _isPickingTime ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: const Color(0xFF4DB6AC).withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        reminderTime.formatted,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4DB6AC),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: const Color(0xFF4DB6AC).withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleToggleCard({
    required String emoji,
    required String title,
    required String description,
    required bool isEnabled,
    required ValueChanged<bool>? onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3B2D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF2D3B2D).withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: const Color(0xFF4DB6AC),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFE57373)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFC62828),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _pickTime(
      ReminderTime current,
      Function(TimeOfDay) onPicked,
      ) async {
    if (_isPickingTime) return;

    setState(() => _isPickingTime = true);

    try {
      final picked = await showTimePicker(
        context: context,
        initialTime: current.toTimeOfDay(),
        builder: (ctx, child) {
          return Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4DB6AC),
                onPrimary: Colors.white,
                surface: Color(0xFFF8FAF5),
                onSurface: Color(0xFF2D3B2D),
              ),
            ),
            child: child!,
          );
        },
      );

      if (!mounted) return;

      if (picked != null) {
        onPicked(picked);
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingTime = false);
      }
    }
  }
}