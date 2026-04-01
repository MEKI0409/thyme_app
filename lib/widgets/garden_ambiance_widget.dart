// widgets/garden_ambiance_widget.dart
// ✅ IMPROVED: Calm Gamification - Visual ambiance that responds to user's mood
// ✅ FIXED: Breathing animation now properly loops
// ✅ FIXED: Positioned widgets now direct children of Stack
// ✅ FIXED: Stack properly fills parent with StackFit.expand
// ✅ FIXED: CustomPaint gets proper size via Positioned.fill
// ✅ FIXED: Raindrop paint side-effect on strokeWidth
// The garden reflects emotions, it doesn't demand actions

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/mood_responsive_garden_service.dart';

class GardenAmbianceWidget extends StatefulWidget {
  final String? currentMood;
  final Widget child;
  final bool showMessage;

  const GardenAmbianceWidget({
    Key? key,
    this.currentMood,
    required this.child,
    this.showMessage = true,
  }) : super(key: key);

  @override
  State<GardenAmbianceWidget> createState() => _GardenAmbianceWidgetState();
}

class _GardenAmbianceWidgetState extends State<GardenAmbianceWidget>
    with TickerProviderStateMixin {
  late AnimationController _windController;
  late AnimationController _particleController;
  late AnimationController _glowController;

  final MoodResponsiveGardenService _gardenService =
  MoodResponsiveGardenService();
  late GardenAmbiance _ambiance;
  List<_FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _ambiance = _gardenService.getGardenAmbiance(widget.currentMood);
    _initializeAnimations();
    _generateParticles();
  }

  @override
  void didUpdateWidget(GardenAmbianceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMood != widget.currentMood) {
      setState(() {
        _ambiance = _gardenService.getGardenAmbiance(widget.currentMood);
        _generateParticles();
      });
    }
  }

  void _initializeAnimations() {
    _windController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _generateParticles() {
    _particles.clear();
    final random = math.Random();

    if (_ambiance.showFallingPetals) {
      for (int i = 0; i < 15; i++) {
        _particles.add(_FloatingParticle(
          type: _ParticleType.petal,
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 10 + random.nextDouble() * 8,
          speed: 0.02 + random.nextDouble() * 0.02,
          swayAmount: 0.05 + random.nextDouble() * 0.03,
          color: [
            const Color(0xFFFFCDD2),
            const Color(0xFFF8BBD9),
            const Color(0xFFE1BEE7),
          ][i % 3],
        ));
      }
    }

    if (_ambiance.showButterflies) {
      for (int i = 0; i < 4; i++) {
        _particles.add(_FloatingParticle(
          type: _ParticleType.butterfly,
          x: random.nextDouble(),
          y: 0.3 + random.nextDouble() * 0.4,
          size: 18 + random.nextDouble() * 8,
          speed: 0.01 + random.nextDouble() * 0.01,
          swayAmount: 0.1 + random.nextDouble() * 0.05,
          color: [
            const Color(0xFFFFEB3B),
            const Color(0xFF4FC3F7),
            const Color(0xFFFF8A65),
            const Color(0xFFBA68C8),
          ][i],
        ));
      }
    }

    if (_ambiance.showSparkles) {
      for (int i = 0; i < 20; i++) {
        _particles.add(_FloatingParticle(
          type: _ParticleType.sparkle,
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 3 + random.nextDouble() * 4,
          speed: 0.005,
          swayAmount: 0.01,
          color: const Color(0xFFFFD54F),
        ));
      }
    }

    if (_ambiance.showFireflies) {
      for (int i = 0; i < 10; i++) {
        _particles.add(_FloatingParticle(
          type: _ParticleType.firefly,
          x: random.nextDouble(),
          y: 0.2 + random.nextDouble() * 0.6,
          size: 6 + random.nextDouble() * 4,
          speed: 0.008 + random.nextDouble() * 0.005,
          swayAmount: 0.08 + random.nextDouble() * 0.04,
          color: const Color(0xFFFFEB3B),
        ));
      }
    }

    if (_ambiance.showRaindrops) {
      for (int i = 0; i < 30; i++) {
        _particles.add(_FloatingParticle(
          type: _ParticleType.raindrop,
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: 2 + random.nextDouble() * 2,
          speed: 0.08 + random.nextDouble() * 0.04,
          swayAmount: 0.005,
          color: const Color(0xFF90CAF9).withValues(alpha: 0.6),
        ));
      }
    }
  }

  @override
  void dispose() {
    _windController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ..._ambiance.skyGradient,
            ..._ambiance.groundGradient,
          ],
          stops: const [0.0, 0.4, 0.6, 1.0],
        ),
      ),
      // ✅ FIX 1: Stack needs StackFit.expand so children get proper size
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ FIX 2: Warm light - Positioned is now a DIRECT child of Stack
          // BEFORE: AnimatedBuilder → return Positioned(...)  ← Positioned was NOT direct Stack child!
          // AFTER:  Positioned → AnimatedBuilder → Container  ← Positioned IS direct Stack child ✓
          if (_ambiance.showWarmLight)
            Positioned(
              top: 50,
              right: 30,
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  return Container(
                    width: 100 + (_glowController.value * 20),
                    height: 100 + (_glowController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber
                              .withValues(alpha: 0.3 + _glowController.value * 0.2),
                          blurRadius: 60,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // ✅ FIX 3: Particles - Positioned.fill gives CustomPaint proper constraints
          // BEFORE: AnimatedBuilder → CustomPaint(size: Size.infinite) ← no constraints → 0x0!
          // AFTER:  Positioned.fill → AnimatedBuilder → CustomPaint ← fills Stack → has real size ✓
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                    windProgress: _windController.value,
                  ),
                );
              },
            ),
          ),

          // Main content
          widget.child,

          // Mood message overlay (subtle, at the top)
          if (widget.showMessage)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Text(
                    _ambiance.message,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Breathing guide button (for anxious mood)
          if (_ambiance.showBreathingGuide)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton.small(
                onPressed: () => _showBreathingExercise(context),
                backgroundColor: Colors.teal[300],
                tooltip: 'Breathing exercise',
                child: const Icon(Icons.air, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showBreathingExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: const _BreathingGuideWidget(),
      ),
    );
  }
}

/// ✅ FIXED: Separate StatefulWidget for breathing animation
/// This ensures proper animation lifecycle and looping
class _BreathingGuideWidget extends StatefulWidget {
  const _BreathingGuideWidget({Key? key}) : super(key: key);

  @override
  State<_BreathingGuideWidget> createState() => _BreathingGuideWidgetState();
}

class _BreathingGuideWidgetState extends State<_BreathingGuideWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  String _breathingPhase = 'Breathe in...';

  @override
  void initState() {
    super.initState();

    _breathController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: const _BreathingCurve(),
      ),
    );

    _breathController.addListener(_updateBreathingPhase);
  }

  void _updateBreathingPhase() {
    final value = _breathController.value;
    String newPhase;

    if (value < 0.4) {
      newPhase = 'Breathe in...';
    } else if (value < 0.5) {
      newPhase = 'Hold...';
    } else if (value < 0.9) {
      newPhase = 'Breathe out...';
    } else {
      newPhase = 'Rest...';
    }

    if (newPhase != _breathingPhase) {
      setState(() {
        _breathingPhase = newPhase;
      });
    }
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 40),

          Text(
            'Take a breath',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.teal[700],
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Follow the circle',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),

          const Spacer(),

          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200 * _breathAnimation.value,
                    height: 200 * _breathAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 150 * _breathAnimation.value,
                    height: 150 * _breathAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.teal.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.spa,
                      size: 40 * _breathAnimation.value,
                      color: Colors.teal[400],
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 40),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _breathingPhase,
              key: ValueKey(_breathingPhase),
              style: TextStyle(
                fontSize: 18,
                color: Colors.teal[600],
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'There\'s no right or wrong way to breathe.\nJust be here, in this moment.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'I feel calmer now',
              style: TextStyle(
                color: Colors.teal[400],
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Custom curve for breathing animation (inhale-hold-exhale-rest)
class _BreathingCurve extends Curve {
  const _BreathingCurve();

  @override
  double transformInternal(double t) {
    if (t < 0.4) {
      return Curves.easeOut.transform(t / 0.4);
    } else if (t < 0.5) {
      return 1.0;
    } else if (t < 0.9) {
      return 1.0 - Curves.easeIn.transform((t - 0.5) / 0.4);
    } else {
      return 0.0;
    }
  }
}

// Particle types
enum _ParticleType { petal, butterfly, sparkle, firefly, raindrop }

// Floating particle data
class _FloatingParticle {
  final _ParticleType type;
  double x;
  double y;
  final double size;
  final double speed;
  final double swayAmount;
  final Color color;

  _FloatingParticle({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.swayAmount,
    required this.color,
  });
}

// Custom painter for particles
class _ParticlePainter extends CustomPainter {
  final List<_FloatingParticle> particles;
  final double progress;
  final double windProgress;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.windProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ FIX 4: Guard against zero-size canvas
    if (size.width <= 0 || size.height <= 0) return;

    for (var particle in particles) {
      final x = (particle.x +
          math.sin(progress * 2 * math.pi + particle.y * 10) *
              particle.swayAmount) *
          size.width;
      double y;

      switch (particle.type) {
        case _ParticleType.petal:
        case _ParticleType.raindrop:
          y = ((particle.y + progress * particle.speed * 10) % 1.2) *
              size.height;
          break;
        case _ParticleType.butterfly:
        case _ParticleType.firefly:
          y = (particle.y +
              math.sin(progress * 2 * math.pi * 0.5 + particle.x * 5) *
                  0.1) *
              size.height;
          break;
        case _ParticleType.sparkle:
          y = particle.y * size.height;
          break;
      }

      final paint = Paint()..color = particle.color;

      switch (particle.type) {
        case _ParticleType.petal:
          _drawPetal(canvas, Offset(x, y), particle.size, paint, progress);
          break;
        case _ParticleType.butterfly:
          _drawButterfly(canvas, Offset(x, y), particle.size, paint, progress);
          break;
        case _ParticleType.sparkle:
          final opacity =
              (math.sin(progress * 4 * math.pi + particle.x * 20) + 1) / 2;
          paint.color = particle.color.withValues(alpha: opacity * 0.8);
          canvas.drawCircle(Offset(x, y), particle.size, paint);
          break;
        case _ParticleType.firefly:
          final glowOpacity =
              (math.sin(progress * 6 * math.pi + particle.x * 15) + 1) / 2;
          paint.color = particle.color.withValues(alpha: glowOpacity * 0.9);
          canvas.drawCircle(
            Offset(x, y),
            particle.size * 2,
            Paint()..color = particle.color.withValues(alpha: glowOpacity * 0.3),
          );
          canvas.drawCircle(Offset(x, y), particle.size, paint);
          break;
        case _ParticleType.raindrop:
        // ✅ FIX 5: Separate paint for stroke, avoid mutating shared paint object
          final strokePaint = Paint()
            ..color = particle.color
            ..strokeWidth = particle.size * 0.5;
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + particle.size * 4),
            strokePaint,
          );
          break;
      }
    }
  }

  void _drawPetal(
      Canvas canvas, Offset center, double size, Paint paint, double progress) {
    final rotation = progress * 2 * math.pi + center.dx;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path()
      ..moveTo(0, -size / 2)
      ..quadraticBezierTo(size / 2, 0, 0, size / 2)
      ..quadraticBezierTo(-size / 2, 0, 0, -size / 2);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawButterfly(
      Canvas canvas, Offset center, double size, Paint paint, double progress) {
    final wingFlap = math.sin(progress * 8 * math.pi) * 0.3 + 0.7;

    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Left wing
    canvas.save();
    canvas.scale(wingFlap, 1);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(-size / 2, 0), width: size, height: size * 0.7),
      paint,
    );
    canvas.restore();

    // Right wing
    canvas.save();
    canvas.scale(wingFlap, 1);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size / 2, 0), width: size, height: size * 0.7),
      paint,
    );
    canvas.restore();

    // Body
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size * 0.15, height: size * 0.5),
      Paint()..color = Colors.brown[400]!,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}