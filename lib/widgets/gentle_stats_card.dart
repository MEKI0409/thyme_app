// widgets/gentle_stats_card.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart';

/// Gentle stats card
class GentleStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final String? gentleMessage;
  final VoidCallback? onTap;

  const GentleStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.accentColor,
    this.gentleMessage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Colors.teal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Colors.grey[800],
                letterSpacing: -0.5,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
            if (gentleMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  gentleMessage!,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class GentleInsightCard extends StatelessWidget {
  final String insight;
  final String? emoji;
  final VoidCallback? onDismiss;

  const GentleInsightCard({
    super.key,
    required this.insight,
    this.emoji,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.withValues(alpha: 0.08),
            Colors.teal.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.teal.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emoji != null) ...[
            Text(
              emoji!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w300,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }
}

/// Mood reflection card
class MoodReflectionCard extends StatelessWidget {
  final String mood;
  final String message;
  final DateTime timestamp;
  final VoidCallback? onTap;

  const MoodReflectionCard({
    super.key,
    required this.mood,
    required this.message,
    required this.timestamp,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Constants.getMoodColor(mood).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Constants.getMoodEmoji(mood),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _capitalize(mood),
                        style: TextStyle(
                          fontSize: 12,
                          color: Constants.getMoodColor(mood),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  ThymeDateUtils.formatRelative(timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}

class GentleProgressWidget extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final bool showMessage;

  const GentleProgressWidget({
    super.key,
    required this.progress,
    required this.label,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(5, (index) {
              final isActive = (index + 1) / 5 <= progress;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPlantStage(index, isActive),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w300,
          ),
        ),
        if (showMessage)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _getGentleProgressMessage(progress),
              style: TextStyle(
                fontSize: 11,
                color: Colors.teal[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlantStage(int stage, bool isActive) {
    final icons = ['🌱', '🌿', '🌸', '🌺', '🌳'];
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.3,
      child: Text(
        icons[stage],
        style: TextStyle(fontSize: 20 + stage * 4.0),
      ),
    );
  }

  String _getGentleProgressMessage(double progress) {
    if (progress < 0.2) {
      return 'Just beginning to grow 🌱';
    } else if (progress < 0.4) {
      return 'Taking root 🌿';
    } else if (progress < 0.6) {
      return 'Growing steadily 🌸';
    } else if (progress < 0.8) {
      return 'Blooming beautifully 🌺';
    } else {
      return 'Flourishing 🌳';
    }
  }
}

class ResourceIndicator extends StatelessWidget {
  final int waterDrops;
  final int sunlightPoints;
  final bool compact;

  const ResourceIndicator({
    super.key,
    required this.waterDrops,
    required this.sunlightPoints,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💧 $waterDrops',
              style: const TextStyle(fontSize: 14, color: Color(0xFF4FC3F7))),
          const SizedBox(width: 12),
          Text('☀️ $sunlightPoints',
              style: const TextStyle(fontSize: 14, color: Color(0xFFFFB74D))),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildResourceItem(
            emoji: '💧',
            value: waterDrops,
            label: 'Water',
            color: const Color(0xFF4FC3F7),
          ),
          Container(
            height: 30,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),
          _buildResourceItem(
            emoji: '☀️',
            value: sunlightPoints,
            label: 'Sunlight',
            color: const Color(0xFFFFB74D),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceItem({
    required String emoji,
    required int value,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

class GentleStreakDisplay extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const GentleStreakDisplay({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(
                  fontSize: currentStreak > 0 ? 28 : 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.orange[700],
                ),
              ),
              Text(
                currentStreak == 1 ? ' day' : ' days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStreakMessage(currentStreak, longestStreak),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // alm Gamification: No pressure, just gentle acknowledgment
  String _getStreakMessage(int current, int longest) {
    if (current == 0) {
      return 'Every moment is a fresh start 🌱';
    } else if (current == 1) {
      return 'You showed up today. That matters 💚';
    } else if (current < 7) {
      return 'Building something beautiful, one day at a time';
    } else if (current < 30) {
      return 'Your garden appreciates your presence 🌿';
    } else if (current >= longest && current > 1) {
      return 'This is your longest journey yet ✨';
    } else {
      return 'Steady and gentle, like the seasons';
    }
  }
}