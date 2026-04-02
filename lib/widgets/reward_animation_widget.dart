// widgets/reward_animation_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Main reward celebration widget
/// Shows floating particles and gentle acknowledgment
class RewardCelebration extends StatefulWidget {
  final int waterDrops;
  final int sunlightPoints;
  final String? message;
  final String? specialUnlock;
  final VoidCallback? onComplete;
  final Duration displayDuration;

  const RewardCelebration({
    Key? key,
    required this.waterDrops,
    required this.sunlightPoints,
    this.message,
    this.specialUnlock,
    this.onComplete,
    this.displayDuration = const Duration(milliseconds: 2500),
  }) : super(key: key);

  /// Show reward celebration as an overlay
  static void show(
      BuildContext context, {
        required int waterDrops,
        required int sunlightPoints,
        String? message,
        String? specialUnlock,
        VoidCallback? onComplete,
      }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Reward',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return RewardCelebration(
          waterDrops: waterDrops,
          sunlightPoints: sunlightPoints,
          message: message,
          specialUnlock: specialUnlock,
          onComplete: () {
            Navigator.of(context).pop();
            onComplete?.call();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<RewardCelebration> createState() => _RewardCelebrationState();
}

class _RewardCelebrationState extends State<RewardCelebration>
    with TickerProviderStateMixin {
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _countController;

  late Animation<double> _pulseAnimation;
  late Animation<int> _waterCountAnimation;
  late Animation<int> _sunCountAnimation;

  final List<_RewardParticle> _particles = [];
  final math.Random _random = math.Random();
  bool _dismissed = false; //防止多次關閉

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateParticles();

    // Auto dismiss after animation
    Future.delayed(widget.displayDuration, _safeDismiss);
  }

  void _safeDismiss() {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    widget.onComplete?.call();
  }

  void _initAnimations() {
    // Particle floating animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..forward();

    // Gentle pulse for the reward card
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // ✅ FIXED: Proper repeat count handling
    void startPulse() {
      _pulseController.forward().then((_) {
        if (mounted) {
          _pulseController.reverse().then((_) {
            if (mounted) {
              _pulseController.forward().then((_) {
                if (mounted) {
                  _pulseController.reverse();
                }
              });
            }
          });
        }
      });
    }

    startPulse();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Count up animation
    _countController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _waterCountAnimation = IntTween(begin: 0, end: widget.waterDrops).animate(
      CurvedAnimation(parent: _countController, curve: Curves.easeOut),
    );

    _sunCountAnimation =
        IntTween(begin: 0, end: widget.sunlightPoints).animate(
          CurvedAnimation(parent: _countController, curve: Curves.easeOut),
        );
  }

  void _generateParticles() {
    // Generate water drop particles
    final waterParticleCount =
    math.min(widget.waterDrops * 3 + 5, 20); // Cap particles
    for (int i = 0; i < waterParticleCount; i++) {
      _particles.add(_RewardParticle(
        type: _ParticleType.water,
        startX: 0.3 + _random.nextDouble() * 0.15,
        startY: 0.5,
        endX: 0.1 + _random.nextDouble() * 0.3,
        endY: -0.1 - _random.nextDouble() * 0.2,
        size: 8 + _random.nextDouble() * 12,
        delay: _random.nextDouble() * 0.3,
        color: Color.lerp(
          const Color(0xFF4FC3F7),
          const Color(0xFF81D4FA),
          _random.nextDouble(),
        )!,
      ));
    }

    // Generate sunlight particles
    final sunParticleCount =
    math.min(widget.sunlightPoints * 3 + 5, 20); // Cap particles
    for (int i = 0; i < sunParticleCount; i++) {
      _particles.add(_RewardParticle(
        type: _ParticleType.sunlight,
        startX: 0.55 + _random.nextDouble() * 0.15,
        startY: 0.5,
        endX: 0.6 + _random.nextDouble() * 0.3,
        endY: -0.1 - _random.nextDouble() * 0.2,
        size: 6 + _random.nextDouble() * 10,
        delay: _random.nextDouble() * 0.3,
        color: Color.lerp(
          const Color(0xFFFFD54F),
          const Color(0xFFFFE082),
          _random.nextDouble(),
        )!,
      ));
    }

    // Special sparkles if there's an unlock
    if (widget.specialUnlock != null) {
      for (int i = 0; i < 15; i++) {
        _particles.add(_RewardParticle(
          type: _ParticleType.sparkle,
          startX: 0.5,
          startY: 0.35,
          endX: 0.2 + _random.nextDouble() * 0.6,
          endY: 0.1 + _random.nextDouble() * 0.5,
          size: 4 + _random.nextDouble() * 6,
          delay: 0.5 + _random.nextDouble() * 0.3,
          color: Color.lerp(
            const Color(0xFFE1BEE7),
            const Color(0xFFCE93D8),
            _random.nextDouble(),
          )!,
        ));
      }
    }
  }

  @override
  void dispose() {
    _particleController.dispose();
    _pulseController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _safeDismiss,
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Particle layer
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _RewardParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                  ),
                );
              },
            ),

            // Central reward card
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: child,
                  );
                },
                child: _buildRewardCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message ?? 'A moment of care for yourself',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.grey[700],
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Resource rewards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Water drops
              _buildResourceReward(
                icon: '💧',
                animation: _waterCountAnimation,
                color: const Color(0xFF4FC3F7),
                label: 'Water',
              ),

              Container(
                height: 50,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey[200],
              ),

              // Sunlight
              _buildResourceReward(
                icon: '☀️',
                animation: _sunCountAnimation,
                color: const Color(0xFFFFB74D),
                label: 'Sunlight',
              ),
            ],
          ),

          // Special unlock notification
          if (widget.specialUnlock != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.1),
                    Colors.pink.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'New color unlocked',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Tap to dismiss hint
          Text(
            'Tap anywhere to continue',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceReward({
    required String icon,
    required Animation<int> animation,
    required Color color,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Text(
              '+${animation.value}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

// Particle types
enum _ParticleType { water, sunlight, sparkle }

// Reward particle data
class _RewardParticle {
  final _ParticleType type;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final double delay;
  final Color color;

  _RewardParticle({
    required this.type,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    required this.delay,
    required this.color,
  });
}

// Custom painter for reward particles
class _RewardParticlePainter extends CustomPainter {
  final List<_RewardParticle> particles;
  final double progress;

  _RewardParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Apply delay
      final adjustedProgress =
      ((progress - particle.delay) / (1 - particle.delay)).clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      // Calculate position with curve
      final curve = Curves.easeOutCubic.transform(adjustedProgress);
      final x = (particle.startX + (particle.endX - particle.startX) * curve) *
          size.width;
      final y = (particle.startY + (particle.endY - particle.startY) * curve) *
          size.height;

      // Fade out at the end
      final opacity =
      (1 - Curves.easeIn.transform(adjustedProgress)).clamp(0.0, 1.0);

      final paint = Paint()..color = particle.color.withValues(alpha: opacity * 0.8);

      switch (particle.type) {
        case _ParticleType.water:
          _drawWaterDrop(canvas, Offset(x, y), particle.size, paint);
          break;
        case _ParticleType.sunlight:
          _drawSunRay(
              canvas, Offset(x, y), particle.size, paint, adjustedProgress);
          break;
        case _ParticleType.sparkle:
          _drawSparkle(
              canvas, Offset(x, y), particle.size, paint, adjustedProgress);
          break;
      }
    }
  }

  void _drawWaterDrop(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Teardrop shape
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(
      center.dx + size * 0.8,
      center.dy,
      center.dx,
      center.dy + size * 0.6,
    );
    path.quadraticBezierTo(
      center.dx - size * 0.8,
      center.dy,
      center.dx,
      center.dy - size,
    );

    canvas.drawPath(path, paint);

    // Small highlight
    canvas.drawCircle(
      Offset(center.dx - size * 0.2, center.dy - size * 0.3),
      size * 0.15,
      Paint()..color = Colors.white.withValues(alpha: paint.color.opacity * 0.6),
    );
  }

  void _drawSunRay(Canvas canvas, Offset center, double size, Paint paint,
      double progress) {
    // Rotating sun ray
    final rotation = progress * math.pi * 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final rayPaint = Paint()
      ..color = paint.color
      ..strokeWidth = size * 0.2
      ..strokeCap = StrokeCap.round;

    // Draw rays
    for (int i = 0; i < 6; i++) {
      canvas.rotate(math.pi / 3);
      canvas.drawLine(
        Offset(0, size * 0.3),
        Offset(0, size),
        rayPaint,
      );
    }

    // Center circle (uses original paint with fill style)
    canvas.drawCircle(Offset.zero, size * 0.4, paint);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint,
      double progress) {
    // Twinkling effect
    final twinkle = (math.sin(progress * math.pi * 4) + 1) / 2;
    final adjustedSize = size * (0.5 + twinkle * 0.5);

    // 4-point star
    final path = Path();
    path.moveTo(center.dx, center.dy - adjustedSize);
    path.lineTo(center.dx + adjustedSize * 0.3, center.dy);
    path.lineTo(center.dx, center.dy + adjustedSize);
    path.lineTo(center.dx - adjustedSize * 0.3, center.dy);
    path.close();

    path.moveTo(center.dx - adjustedSize, center.dy);
    path.lineTo(center.dx, center.dy + adjustedSize * 0.3);
    path.lineTo(center.dx + adjustedSize, center.dy);
    path.lineTo(center.dx, center.dy - adjustedSize * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RewardParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Floating reward indicator - shows briefly inline (for less intrusive feedback)
class FloatingRewardIndicator extends StatefulWidget {
  final int waterDrops;
  final int sunlightPoints;
  final Offset startPosition;
  final VoidCallback? onComplete;

  const FloatingRewardIndicator({
    Key? key,
    required this.waterDrops,
    required this.sunlightPoints,
    required this.startPosition,
    this.onComplete,
  }) : super(key: key);

  @override
  State<FloatingRewardIndicator> createState() =>
      _FloatingRewardIndicatorState();
}

class _FloatingRewardIndicatorState extends State<FloatingRewardIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: -80).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.startPosition.dx - 40,
          top: widget.startPosition.dy + _floatAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.waterDrops > 0)
                    Text(
                      '+${widget.waterDrops} 💧',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4FC3F7),
                      ),
                    ),
                  if (widget.waterDrops > 0 && widget.sunlightPoints > 0)
                    const SizedBox(width: 8),
                  if (widget.sunlightPoints > 0)
                    Text(
                      '+${widget.sunlightPoints} ☀️',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB74D),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gentle ripple effect for resource collection
class ResourceRipple extends StatefulWidget {
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const ResourceRipple({
    Key? key,
    required this.color,
    this.size = 100,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ResourceRipple> createState() => _ResourceRippleState();
}

class _ResourceRippleState extends State<ResourceRipple>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * (1 + _controller.value),
          height: widget.size * (1 + _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1 - _controller.value),
              width: 3 * (1 - _controller.value),
            ),
          ),
        );
      },
    );
  }
}

/// ✅ NEW: Gentle acknowledgment toast
class GentleToast {
  static void show(
      BuildContext context, {
        required String message,
        Duration duration = const Duration(seconds: 2),
        String? emoji,
      }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _GentleToastWidget(
        message: message,
        emoji: emoji,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }
}

class _GentleToastWidget extends StatefulWidget {
  final String message;
  final String? emoji;
  final VoidCallback onDismiss;
  final Duration duration;

  const _GentleToastWidget({
    Key? key,
    required this.message,
    this.emoji,
    required this.onDismiss,
    required this.duration,
  }) : super(key: key);

  @override
  State<_GentleToastWidget> createState() => _GentleToastWidgetState();
}

class _GentleToastWidgetState extends State<_GentleToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.emoji != null) ...[
                  Text(widget.emoji!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w400,
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
}