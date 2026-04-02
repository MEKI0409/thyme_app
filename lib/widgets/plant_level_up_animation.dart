// widgets/plant_level_up_animation.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/theme.dart';
import '../utils/constants.dart';
import 'cute_garden_icons.dart';

class PlantLevelUpAnimation {
  static void show(
      BuildContext context, {
        required int oldLevel,
        required int newLevel,
        VoidCallback? onComplete,
      }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return _LevelUpAnimationContent(
          oldLevel: oldLevel,
          newLevel: newLevel,
          onComplete: () {
            Navigator.of(context).pop();
            onComplete?.call();
          },
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.elasticOut,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _LevelUpAnimationContent extends StatefulWidget {
  final int oldLevel;
  final int newLevel;
  final VoidCallback onComplete;

  const _LevelUpAnimationContent({
    required this.oldLevel,
    required this.newLevel,
    required this.onComplete,
  });

  @override
  State<_LevelUpAnimationContent> createState() => _LevelUpAnimationContentState();
}

class _LevelUpAnimationContentState extends State<_LevelUpAnimationContent>
    with TickerProviderStateMixin {

  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;

  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  bool _showContent = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 粒子動畫
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _generateParticles();

    _startAnimation();
  }

  void _generateParticles() {
    final colors = [
      const Color(0xFFFFD54F),
      const Color(0xFFFF69B4),
      const Color(0xFF9DD4B0),
      const Color(0xFFD4B8E0),
      const Color(0xFF90CAF9),
      const Color(0xFFFFCC80),
    ];

    for (int i = 0; i < 30; i++) {
      _particles.add(_ConfettiParticle(
        angle: _random.nextDouble() * math.pi * 2,
        speed: 100 + _random.nextDouble() * 150,
        size: 6 + _random.nextDouble() * 8,
        color: colors[_random.nextInt(colors.length)],
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() => _showContent = true);
    _particleController.forward();

    // 三秒自動關閉
    await Future.delayed(const Duration(seconds: 3));
    _safeDismiss();
  }

  void _safeDismiss() {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _safeDismiss,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 粒子效果
            ListenableBuilder(
              listenable: _particleController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _particleController.value,
                    center: Offset(
                      MediaQuery.of(context).size.width / 2,
                      MediaQuery.of(context).size.height / 2 - 50,
                    ),
                  ),
                );
              },
            ),

            Center(
              child: AnimatedOpacity(
                opacity: _showContent ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 植物图标 + 光环
                      ListenableBuilder(
                        listenable: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: child,
                          );
                        },
                        child: _buildPlantDisplay(),
                      ),

                      const SizedBox(height: 30),

                      // LEVEL UP 文字
                      _buildLevelUpText(),

                      const SizedBox(height: 40),

                      // 点击提示
                      Text(
                        'Tap to continue',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantDisplay() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            CuteTheme.cream,
            CuteTheme.mintGreen.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: CuteTheme.flowerCenter.withValues(alpha: 0.3),
            blurRadius: 50,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: PlantLevelIcon(
          level: widget.newLevel,
          size: 100,
        ),
      ),
    );
  }

  Widget _buildLevelUpText() {
    return Column(
      children: [
        // LEVEL UP!
        FittedBox(
          fit: BoxFit.scaleDown,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFD700),
                Color(0xFFFF6B6B),
                Color(0xFFFF69B4),
              ],
            ).createShader(bounds),
            child: Text(
              '🎉 LEVEL UP! 🎉',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 等級變化
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  CuteTheme.primaryGreen,
                  CuteTheme.leafGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: CuteTheme.primaryGreen.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lv.${widget.oldLevel}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Text(
                  'Lv.${widget.newLevel}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          '${_getPlantEmoji(widget.newLevel)} ${Constants.getPlantStageName(widget.newLevel)}',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  String _getPlantEmoji(int level) {
    if (level <= 0) return '🌱';
    if (level <= 2) return '🌿';
    if (level <= 4) return '🌸';
    if (level <= 6) return '🌺';
    if (level <= 8) return '🌻';
    return '🌳';
  }
}

// 粒子数据
class _ConfettiParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double rotationSpeed;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotationSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;
  final Offset center;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
    required this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final distance = progress * p.speed;
      final x = center.dx + math.cos(p.angle) * distance;
      final y = center.dy + math.sin(p.angle) * distance + progress * 50; // 重力

      // 淡出
      final opacity = (1 - progress * 0.7).clamp(0.0, 1.0);
      // 縮放
      final scale = progress < 0.2 ? progress / 0.2 : 1.0;

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * p.rotationSpeed);

      canvas.drawCircle(Offset.zero, p.size * scale / 2, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}