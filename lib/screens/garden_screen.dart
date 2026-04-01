// screens/garden_screen.dart
// Updated version: Using macaron color palette flat cute icons
// Using shared widget library
// Added plant level up celebration animation

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../controllers/auth_controller.dart';
import '../controllers/garden_controller.dart';
import '../controllers/mood_controller.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/cute_garden_icons.dart';
import '../widgets/cute_widgets.dart';
import '../widgets/plant_level_up_animation.dart';
import '../widgets/garden_ambiance_widget.dart'; // ✅ NEW: 情绪响应环境效果
import '../services/garden_audio_service.dart'; // ✅ NEW: 环境音效服务
import '../services/mood_responsive_garden_service.dart'; // ✅ FIX: 用于获取 ambiance

class GardenScreen extends StatefulWidget {
  const GardenScreen({Key? key}) : super(key: key);

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen>
    with TickerProviderStateMixin {
  late AnimationController _breatheController;
  late AnimationController _floatController;
  late AnimationController _sparkleController;
  late Animation<double> _breatheAnimation;
  late Animation<double> _floatAnimation;

  // ✅ NEW: 环境音效服务
  final GardenAudioService _audioService = GardenAudioService();
  final MoodResponsiveGardenService _gardenService = MoodResponsiveGardenService(); // ✅ FIX: 用于获取 ambiance
  String? _lastMood; // 跟踪情绪变化，避免重复触发音效

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Breathing animation - plant slight scaling
    _breatheController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    // Float animation - plant slight vertical movement
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Sparkle animation
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _floatController.dispose();
    _sparkleController.dispose();
    _audioService.stopWithFadeOut(); // ✅ NEW: 离开花园页面时停止音效
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GardenController, MoodController>(
      builder: (context, gardenController, moodController, _) {
        if (gardenController.isLoading) {
          return _buildLoadingState();
        }

        // ✅ FIX: 同步 MoodController 的情绪到 GardenController
        // 这是关键修复！之前 gardenController.currentMood 永远是 null，
        // 因为没有任何地方调用 gardenController.setCurrentMood()。
        // MoodController.currentMood 在用户写日记后会更新，
        // 但 GardenController 不知道这个变化。
        final moodFromMoodController = moodController.currentMood;
        if (moodFromMoodController != null &&
            moodFromMoodController != gardenController.currentMood) {
          // 用 postFrameCallback 避免在 build 中修改其他 provider 的状态
          WidgetsBinding.instance.addPostFrameCallback((_) {
            gardenController.setCurrentMood(moodFromMoodController);
          });
        }

        final garden = gardenController.gardenState;
        final ambiance = gardenController.currentAmbiance;
        // ✅ FIX: 优先使用 MoodController 的情绪（更实时），
        // 回退到 GardenController 的（可能还没同步）
        final currentMood = moodFromMoodController ?? gardenController.currentMood;
        final selectedColor = Constants.parseColor(garden.selectedColor);

        // ✅ NEW: 情绪变化时切换环境音效
        if (currentMood != _lastMood) {
          _lastMood = currentMood;
          final soundToPlay = ambiance?.ambientSound ??
              _gardenService.getGardenAmbiance(currentMood).ambientSound;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _audioService.playWithFadeIn(soundToPlay);
          });
        }

        // ✅ NEW: GardenAmbianceWidget 包裹整个花园，启用情绪响应视觉效果
        // 根据情绪显示：蝴蝶(happy)、花瓣(stressed)、萤火虫(calm)、
        // 雨滴(sad)、星光(happy)、暖光(sad/happy/calm)、呼吸引导(anxious)
        return GardenAmbianceWidget(
          currentMood: currentMood,
          showMessage: false, // 我们用自己的 _buildAmbianceHeader 显示消息
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Ambiance message
                if (ambiance != null)
                  _buildAmbianceHeader(ambiance.message),

                // Main garden area
                _buildGardenArea(garden, selectedColor, gardenController),

                // Resources card
                _buildResourcesCard(garden, gardenController),

                // Grow button
                _buildGrowButton(garden, gardenController),

                // Color shop
                _buildColorShop(garden, gardenController),

                // Achievements area
                if (garden.achievements.isNotEmpty)
                  _buildAchievements(garden.achievements),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListenableBuilder(
            listenable: _breatheController,
            builder: (context, _) {
              return Transform.scale(
                scale: _breatheAnimation.value,
                child: const CuteSeedling(size: 64),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Growing your garden...',
            style: TextStyle(
              color: GardenColors.textMedium,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getBackgroundColors(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy':
        return [const Color(0xFFFFFBE6), GardenColors.softYellow.withValues(alpha: 0.3)];
      case 'calm':
        return [GardenColors.mintGreenLight, GardenColors.mintGreen.withValues(alpha: 0.3)];
      case 'anxious':
        return [GardenColors.lavenderLight, GardenColors.lavender.withValues(alpha: 0.3)];
      case 'sad':
        return [const Color(0xFFE8F4F8), GardenColors.softBlue.withValues(alpha: 0.3)];
      default:
        return [GardenColors.mintGreenLight, GardenColors.mintGreen.withValues(alpha: 0.4)];
    }
  }

  Widget _buildAmbianceHeader(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GardenColors.mintGreen.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          const CuteSparkle(size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: GardenColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGardenArea(dynamic garden, Color selectedColor, GardenController controller) {
    return Container(
      height: 320,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            selectedColor.withValues(alpha: 0.12),
            selectedColor.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background decoration rings
            ...List.generate(3, (index) {
              return ListenableBuilder(
                listenable: _sparkleController,
                builder: (context, _) {
                  final progress = (_sparkleController.value + index * 0.3) % 1.0;
                  return Container(
                    width: 180 + index * 50.0,
                    height: 180 + index * 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GardenColors.lavender.withValues(alpha: 0.15 * (1 - progress)),
                        width: 2,
                      ),
                    ),
                  );
                },
              );
            }),

            // Floating flower decorations
            ...List.generate(6, (index) => _buildFloatingFlower(index)),

            // Main plant
            ListenableBuilder(
              listenable: Listenable.merge([_breatheAnimation, _floatAnimation]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: Transform.scale(
                    scale: _breatheAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Plant aura background
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedColor.withValues(alpha: 0.15),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: PlantLevelIcon(
                        level: garden.plantLevel,
                        size: 80,
                        color: selectedColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: GardenColors.cream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selectedColor.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: selectedColor.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CuteSeedling(size: 18, color: selectedColor),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${garden.plantLevel}',
                            style: TextStyle(
                              color: selectedColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Description text
                    // ✅ FIXED: FittedBox prevents horizontal overflow when
                    // breathe animation scales the Column beyond container width
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        controller.getPlantDescription(),
                        style: const TextStyle(
                          color: GardenColors.textMedium,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating flower decoration
  Widget _buildFloatingFlower(int index) {
    final random = math.Random(index);
    final startX = random.nextDouble() * 280 - 140;
    final startY = random.nextDouble() * 180 - 90;
    final size = 12.0 + random.nextDouble() * 10;

    return ListenableBuilder(
      listenable: _sparkleController,
      builder: (context, _) {
        final progress = (_sparkleController.value + index * 0.15) % 1.0;
        final y = startY - progress * 40;
        final opacity = math.sin(progress * math.pi) * 0.7;

        return Transform.translate(
          offset: Offset(startX, y),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: index % 3 == 0
                ? CuteFlower(size: size, color: GardenColors.lavender)
                : index % 3 == 1
                ? Container(
              width: size * 0.5,
              height: size * 0.8,
              decoration: BoxDecoration(
                color: GardenColors.leafGreen.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(size),
              ),
            )
                : Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: const BoxDecoration(
                color: GardenColors.cream,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResourcesCard(dynamic garden, GardenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GardenColors.mintGreen.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: GardenColors.mintGreen.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GardenColors.mintGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const CuteLeaves(size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Garden Resources',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: GardenColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildResourceItem(
                  icon: const CuteWaterDrop(size: 32),
                  label: 'Water Drops',
                  value: garden.waterDrops,
                  color: const Color(0xFF3BA3D0),
                  bgColor: GardenColors.softBlue.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResourceItem(
                  icon: const CuteSunlight(size: 32),
                  label: 'Sunlight',
                  value: garden.sunlightPoints,
                  color: const Color(0xFFD4940A),
                  bgColor: GardenColors.softYellow.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Show water and sunlight requirements
          if (garden.plantLevel < 10) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next level requires:',
                  style: TextStyle(fontSize: 13, color: GardenColors.textMedium, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                _buildResourceProgress(
                  label: 'Water',
                  current: garden.waterDrops,
                  required: garden.getWaterNeededForNextLevel(),
                  color: const Color(0xFF3BA3D0),
                  bgColor: GardenColors.softBlue.withValues(alpha: 0.25),
                  icon: const CuteWaterDrop(size: 16),
                ),
                const SizedBox(height: 10),
                _buildResourceProgress(
                  label: 'Sunlight',
                  current: garden.sunlightPoints,
                  required: garden.getSunlightNeededForNextLevel(),
                  color: const Color(0xFFD4940A),
                  bgColor: GardenColors.softYellow.withValues(alpha: 0.35),
                  icon: const CuteSunlight(size: 16),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    GardenColors.mintGreen.withValues(alpha: 0.2),
                    GardenColors.lavender.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CuteTree(size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Maximum level reached! 🎉',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: GardenColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourceProgress({
    required String label,
    required int current,
    required int required,
    required Color color,
    required Color bgColor,
    required Widget icon,
  }) {
    final progress = (current / required).clamp(0.0, 1.0);
    final isEnough = current >= required;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 左侧：图标 + 标签（固定宽度，不抢空间）
            icon,
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: GardenColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // 右侧：数值（用 FittedBox 防止溢出）
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isEnough ? GardenColors.mintGreen : color,
                    ),
                  ),
                  Text(
                    ' / $required',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GardenColors.textMedium,
                    ),
                  ),
                  if (isEnough) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.check_circle, size: 16, color: GardenColors.mintGreen),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              isEnough ? GardenColors.mintGreen : color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResourceItem({
    required Widget icon,
    required String label,
    required int value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          icon,
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: GardenColors.textMedium,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildGrowButton(dynamic garden, GardenController controller) {
    final canGrow = garden.canGrow();
    final waterNeeded = garden.getWaterNeededForNextLevel();
    final sunlightNeeded = garden.getSunlightNeededForNextLevel();
    final needsWater = garden.waterDrops < waterNeeded;
    final needsSunlight = garden.sunlightPoints < sunlightNeeded;

    String disabledText;
    Widget disabledIcon;
    if (garden.plantLevel >= 10) {
      disabledText = 'Maximum level reached! 🌳';
      disabledIcon = const CuteTree(size: 24);
    } else if (needsWater && needsSunlight) {
      disabledText = 'Need more water & sunlight';
      disabledIcon = const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CuteWaterDrop(size: 20),
          SizedBox(width: 4),
          CuteSunlight(size: 20),
        ],
      );
    } else if (needsWater) {
      disabledText = 'Need ${waterNeeded - garden.waterDrops} more water';
      disabledIcon = const CuteWaterDrop(size: 24);
    } else if (needsSunlight) {
      disabledText = 'Need ${sunlightNeeded - garden.sunlightPoints} more sunlight';
      disabledIcon = const CuteSunlight(size: 24);
    } else {
      disabledText = 'Keep growing!';
      disabledIcon = const CuteSeedling(size: 24);
    }

    return Container(
      margin: const EdgeInsets.all(20),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canGrow
            ? () async {
          final authController = Provider.of<AuthController>(context, listen: false);
          final user = authController.currentUser;
          if (user == null) return; // ✅ FIXED (v3): null 安全检查
          final oldLevel = garden.plantLevel;
          final success = await controller.growPlant(user.uid);
          if (success && mounted) {
            final newLevel = controller.gardenState.plantLevel;
            PlantLevelUpAnimation.show(
              context,
              oldLevel: oldLevel,
              newLevel: newLevel,
              onComplete: () {},
            );
          }
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canGrow ? GardenColors.mintGreen : GardenColors.creamDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: canGrow ? GardenColors.mintGreenDark : Colors.transparent,
              width: 2,
            ),
          ),
          elevation: canGrow ? 4 : 0,
          shadowColor: GardenColors.mintGreen.withValues(alpha: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                canGrow ? 'Grow Your Plant 🌱' : disabledText,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: canGrow ? Colors.white : GardenColors.textMedium.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            canGrow ? const CuteSeedling(size: 24) : disabledIcon,
          ],
        ),
      ),
    );
  }

  void _showGrowthCelebration(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: GardenColors.mintGreen, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CuteCelebration(size: 75),
              const SizedBox(height: 20),
              const Text(
                'Growth Achieved!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GardenColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 15,
                  color: GardenColors.textMedium,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GardenColors.mintGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: GardenColors.mintGreenDark, width: 2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue Growing',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    CuteLeaves(size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorShop(dynamic garden, GardenController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GardenColors.lavender, width: 2),
        boxShadow: [
          BoxShadow(
            color: GardenColors.lavender.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  color: GardenColors.lavenderLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GardenColors.lavender, width: 1),
                ),
                child: const Icon(Icons.palette_outlined, color: GardenColors.lavenderDark, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Garden Colors',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: GardenColors.lavenderDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: GardenColors.softYellow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFD4940A).withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CuteSunlight(size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${garden.sunlightPoints}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD4940A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Unlock new colors with sunlight points',
            style: TextStyle(
              fontSize: 13,
              color: GardenColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: Constants.gardenColors.map((colorData) {
              final hex = colorData['hex'] as String;
              final name = colorData['name'] as String;
              final cost = colorData['cost'] as int;
              final isUnlocked = garden.unlockedColors.contains(hex);
              final isSelected = garden.selectedColor == hex;
              final canUnlock = garden.sunlightPoints >= cost;
              final color = Constants.parseColor(hex);

              return GestureDetector(
                onTap: () async {
                  if (isUnlocked) {
                    final authController = Provider.of<AuthController>(context, listen: false);
                    final user = authController.currentUser;
                    if (user == null) return; // ✅ FIXED (v3): null 安全检查
                    await controller.selectColor(user.uid, hex);
                  } else if (canUnlock) {
                    _showUnlockDialog(hex, name, cost, controller, color);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withValues(alpha: 0.15)
                        : GardenColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isUnlocked ? color : GardenColors.creamDark,
                              shape: BoxShape.circle,
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                                  : null,
                            ),
                          ),
                          if (!isUnlocked)
                            Icon(
                              Icons.lock_rounded,
                              size: 16,
                              color: GardenColors.mintGreenDark.withValues(alpha: 0.4),
                            ),
                          if (isSelected)
                            const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // ✅ FIXED: FittedBox ensures long color names like
                      // "Pink Bliss" scale down instead of overflowing by ~6px
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 11,
                            color: GardenColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (!isUnlocked)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CuteSunlight(size: 12),
                            const SizedBox(width: 2),
                            Text(
                              '$cost',
                              style: TextStyle(
                                fontSize: 11,
                                color: canUnlock
                                    ? const Color(0xFFD4940A)
                                    : GardenColors.creamDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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

  void _showUnlockDialog(String hex, String name, int cost,
      GardenController controller, Color color) {
    // ✅ FIXED (v3): 在 dialog 外捕获引用，防止 pop 后 context 失效
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;
    if (user == null) return; // ✅ FIXED (v3): null 安全检查
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: GardenColors.cream, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // ✅ FIXED: Wrap in Flexible to prevent right overflow
            Flexible(
              child: Text(
                'Unlock $name?',
                style: const TextStyle(
                  color: GardenColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Row(
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      'This will cost $cost ',
                      style: const TextStyle(color: GardenColors.textMedium, fontSize: 15),
                    ),
                  ),
                  const CuteSunlight(size: 18),
                  const Text(
                    ' sunlight',
                    style: TextStyle(color: GardenColors.textMedium, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Maybe Later',
              style: TextStyle(color: GardenColors.textMedium.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await controller.unlockColor(
                user.uid,
                hex,
                cost,
              );
              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // ✅ FIXED: Wrap in Expanded to prevent right overflow
                        Expanded(
                          child: Text(
                            '$name unlocked!',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CuteSparkle(size: 20),
                      ],
                    ),
                    backgroundColor: GardenColors.mintGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 3,
            ),
            child: const Text(
              'Unlock',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(List<String> achievements) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: GardenColors.softYellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: GardenColors.softYellow.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  color: GardenColors.softYellow.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4940A).withValues(alpha: 0.3), width: 1),
                ),
                child: const CuteTrophy(size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4940A),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: GardenColors.softYellow.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4940A).withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${achievements.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFFD4940A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: achievements.map((achievement) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: GardenColors.cream,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GardenColors.softYellow, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CuteStar(size: 18),
                    const SizedBox(width: 8),
                    // ✅ FIXED: Use Flexible to prevent long achievement names from overflowing
                    Flexible(
                      child: Text(
                        achievement,
                        style: const TextStyle(
                          fontSize: 13,
                          color: GardenColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}