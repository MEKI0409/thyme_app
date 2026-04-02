// screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late AnimationController _clockController;

  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotateAnimation;
  late Animation<double> _flowerBloomAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _sloganFadeAnimation;
  late Animation<double> _sloganSlideAnimation;
  late Animation<double> _fadeOutAnimation;
  late Animation<double> _clockHandAnimation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimationSequence();
  }

  void _initAnimations() {

    _iconController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );


    _clockController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );


    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );


    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.elasticOut,
      ),
    );

    _iconRotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeOut,
      ),
    );

    _flowerBloomAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _clockHandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _clockController,
        curve: Curves.easeInOut,
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _sloganFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _sloganSlideAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );
  }

  void _startAnimationSequence() async {
    if (_isDisposed) return;

    await Future.delayed(const Duration(milliseconds: 200));
    if (_isDisposed || !mounted) return;
    _iconController.forward();
    _clockController.repeat();

    await Future.delayed(const Duration(milliseconds: 600));
    if (_isDisposed || !mounted) return;
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 2500));
    if (_isDisposed || !mounted) return;
    await _fadeController.forward();

    if (_isDisposed || !mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _iconController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    _clockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_fadeController, _iconController, _textController, _clockController]),
      builder: (context, _) {
        return Opacity(
          opacity: _fadeOutAnimation.value,
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: CuteTheme.primaryGradient,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    _buildThymeIcon(),

                    const SizedBox(height: 48),

                    _buildTitle(),

                    const SizedBox(height: 16),

                    _buildSlogan(),

                    const Spacer(flex: 3),

                    _buildBottomDecoration(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ); // closes Opacity
      }, // closes builder
    ); // closes ListenableBuilder
  }

  Widget _buildThymeIcon() {
    return Transform.scale(
      scale: _iconScaleAnimation.value,
      child: Transform.rotate(
        angle: _iconRotateAnimation.value,
        child: SizedBox(
          height: 200,
          width: 200,
          child: CustomPaint(
            painter: _ThymeIconPainter(
              bloomProgress: _flowerBloomAnimation.value,
              clockProgress: _clockHandAnimation.value,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Opacity(
      opacity: _titleFadeAnimation.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlideAnimation.value),
        child: Text(
          'Thyme',
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.w300,
            color: CuteTheme.deepGreen,
            letterSpacing: 4,
          ),
        ),
      ),
    );
  }

  Widget _buildSlogan() {
    return Opacity(
      opacity: _sloganFadeAnimation.value,
      child: Transform.translate(
        offset: Offset(0, _sloganSlideAnimation.value),
        child: Text(
          'Take your thyme to bloom',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: CuteTheme.textGreen,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDecoration() {
    return Opacity(
      opacity: _sloganFadeAnimation.value * 0.6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSmallFlower(),
          const SizedBox(width: 12),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: CuteTheme.flowerCenter.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          _buildSmallFlower(),
        ],
      ),
    );
  }

  Widget _buildSmallFlower() {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: CuteTheme.petalPink.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: CuteTheme.flowerCenter,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _ThymeIconPainter extends CustomPainter {
  final double bloomProgress;
  final double clockProgress;

  _ThymeIconPainter({
    required this.bloomProgress,
    required this.clockProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 200;

    _drawDecorationDots(canvas, size, scale);

    _drawLeaves(canvas, center, scale);

    _drawFlowers(canvas, center, scale);

    _drawClock(canvas, center, scale);
  }

  void _drawDecorationDots(Canvas canvas, Size size, double scale) {
    final dotPaint = Paint()..style = PaintingStyle.fill;

    final dots = <Map<String, double>>[
      {'x': size.width * 0.15, 'y': size.height * 0.15, 'r': 4.0 * scale, 'o': 0.3},
      {'x': size.width * 0.88, 'y': size.height * 0.18, 'r': 3.0 * scale, 'o': 0.25},
      {'x': size.width * 0.12, 'y': size.height * 0.85, 'r': 3.0 * scale, 'o': 0.2},
      {'x': size.width * 0.9, 'y': size.height * 0.88, 'r': 4.0 * scale, 'o': 0.25},
    ];

    for (final dot in dots) {
      dotPaint.color = Colors.white.withValues(alpha: dot['o']! * bloomProgress);
      canvas.drawCircle(Offset(dot['x']!, dot['y']!), dot['r']!, dotPaint);
    }
  }

  void _drawLeaves(Canvas canvas, Offset center, double scale) {
    final leafPaint = Paint()
      ..color = CuteTheme.primaryGreen
      ..style = PaintingStyle.fill;

    final ringRadius = 70 * scale;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45 + 22.5) * math.pi / 180;
      final leafCenter = Offset(
        center.dx + ringRadius * math.cos(angle),
        center.dy + ringRadius * math.sin(angle),
      );

      canvas.save();
      canvas.translate(leafCenter.dx, leafCenter.dy);
      canvas.rotate(angle + math.pi / 2);

      final leafRect = Rect.fromCenter(
        center: Offset.zero,
        width: 14 * scale * bloomProgress,
        height: 8 * scale * bloomProgress,
      );
      canvas.drawOval(leafRect, leafPaint);

      canvas.restore();
    }
  }

  void _drawFlowers(Canvas canvas, Offset center, double scale) {
    final petalColors = [
      CuteTheme.petalPink,
      CuteTheme.petalLight,
      CuteTheme.petalMid,
      CuteTheme.petalLight,
      CuteTheme.petalPink,
    ];
    final ringRadius = 70 * scale;

    for (int i = 0; i < 8; i++) {
      final angle = i * 45 * math.pi / 180;
      final flowerPos = Offset(
        center.dx + ringRadius * math.cos(angle),
        center.dy + ringRadius * math.sin(angle),
      );

      // 5 petals
      for (int j = 0; j < 5; j++) {
        final petalAngle = (j * 72 + i * 15) * math.pi / 180;
        final petalOffset = Offset(
          flowerPos.dx + 8 * scale * bloomProgress * math.cos(petalAngle),
          flowerPos.dy + 8 * scale * bloomProgress * math.sin(petalAngle),
        );

        final petalPaint = Paint()
          ..color = petalColors[j]
          ..style = PaintingStyle.fill;

        canvas.save();
        canvas.translate(petalOffset.dx, petalOffset.dy);
        canvas.rotate(petalAngle);

        final petalRect = Rect.fromCenter(
          center: Offset.zero,
          width: 10 * scale * bloomProgress,
          height: 7 * scale * bloomProgress,
        );
        canvas.drawOval(petalRect, petalPaint);
        canvas.restore();
      }

      final centerPaint = Paint()
        ..color = CuteTheme.flowerCenter
        ..style = PaintingStyle.fill;
      canvas.drawCircle(flowerPos, 4 * scale * bloomProgress, centerPaint);

      final centerLightPaint = Paint()
        ..color = CuteTheme.lavender
        ..style = PaintingStyle.fill;
      canvas.drawCircle(flowerPos, 2.5 * scale * bloomProgress, centerLightPaint);
    }
  }

  void _drawClock(Canvas canvas, Offset center, double scale) {
    final facePaint = Paint()
      ..color = CuteTheme.cream
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 42 * scale, facePaint);

    final borderPaint = Paint()
      ..color = CuteTheme.borderLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * scale;
    canvas.drawCircle(center, 42 * scale, borderPaint);

    final mainDotPaint = Paint()
      ..color = CuteTheme.lavender
      ..style = PaintingStyle.fill;

    final mainDotRadius = 32 * scale;
    for (int i = 0; i < 4; i++) {
      final angle = i * 90 * math.pi / 180 - math.pi / 2;
      final dotCenter = Offset(
        center.dx + mainDotRadius * math.cos(angle),
        center.dy + mainDotRadius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 3.5 * scale, mainDotPaint);
    }

    final smallDotPaint = Paint()
      ..color = CuteTheme.petalPink
      ..style = PaintingStyle.fill;

    final smallDotRadius = 30 * scale;
    for (int i = 0; i < 12; i++) {
      if (i % 3 == 0) continue; // Skip main marker positions
      final angle = i * 30 * math.pi / 180 - math.pi / 2;
      final dotCenter = Offset(
        center.dx + smallDotRadius * math.cos(angle),
        center.dy + smallDotRadius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, 2 * scale, smallDotPaint);
    }

    final hourAngle = clockProgress * 2 * math.pi * 0.1 - math.pi / 2;
    final hourHandPaint = Paint()
      ..color = CuteTheme.primaryGreen
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 22 * scale * math.cos(hourAngle),
        center.dy + 22 * scale * math.sin(hourAngle),
      ),
      hourHandPaint,
    );

    // Minute hand (fast rotation)
    final minuteAngle = clockProgress * 2 * math.pi - math.pi / 2;
    final minuteHandPaint = Paint()
      ..color = CuteTheme.mintGreen
      ..strokeWidth = 3 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + 28 * scale * math.cos(minuteAngle),
        center.dy + 28 * scale * math.sin(minuteAngle),
      ),
      minuteHandPaint,
    );

    final centerDotPaint = Paint()
      ..color = CuteTheme.primaryGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5 * scale, centerDotPaint);

    final centerDotLightPaint = Paint()
      ..color = CuteTheme.cream
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5 * scale, centerDotLightPaint);
  }

  @override
  bool shouldRepaint(covariant _ThymeIconPainter oldDelegate) {
    return oldDelegate.bloomProgress != bloomProgress ||
        oldDelegate.clockProgress != clockProgress;
  }
}