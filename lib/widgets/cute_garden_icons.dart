// widgets/cute_garden_icons.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class GardenColors {

  static const Color mintGreen = Color(0xFF8BC9A3);
  static const Color mintGreenLight = Color(0xFFD5EDDF);
  static const Color mintGreenDark = Color(0xFF4A9B6F);


  static const Color lavender = Color(0xFFC4B0D9);
  static const Color lavenderLight = Color(0xFFEDE5F5);
  static const Color lavenderDark = Color(0xFF8B71AC);


  static const Color cream = Color(0xFFFFFDF7);
  static const Color creamDark = Color(0xFFE8E4D9);


  static const Color softYellow = Color(0xFFFFE566);
  static const Color softPink = Color(0xFFFFB5B5);
  static const Color softBlue = Color(0xFF7ECBEB);
  static const Color softOrange = Color(0xFFFFCC80);


  static const Color dotPurple = Color(0xFFB8A5CC);
  static const Color leafGreen = Color(0xFF5A9E78);


  static const Color textDark = Color(0xFF3D6B50);
  static const Color textMedium = Color(0xFF5A8A6D);
}


class CuteWaterDrop extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteWaterDrop({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _WaterDropPainter(color ?? GardenColors.softBlue),
      ),
    );
  }
}

class _WaterDropPainter extends CustomPainter {
  final Color color;
  _WaterDropPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final dropPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.5, h * 0.08);
    path.quadraticBezierTo(w * 0.15, h * 0.5, w * 0.15, h * 0.62);
    path.quadraticBezierTo(w * 0.15, h * 0.92, w * 0.5, h * 0.92);
    path.quadraticBezierTo(w * 0.85, h * 0.92, w * 0.85, h * 0.62);
    path.quadraticBezierTo(w * 0.85, h * 0.5, w * 0.5, h * 0.08);
    path.close();
    canvas.drawPath(path, dropPaint);


    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.35, h * 0.45), w * 0.1, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterDropPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteSunlight extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteSunlight({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunlightPainter(color ?? GardenColors.softYellow),
      ),
    );
  }
}

class _SunlightPainter extends CustomPainter {
  final Color color;
  _SunlightPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.25;


    final rayPaint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final innerRadius = radius * 1.4;
      final outerRadius = radius * 1.9;

      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + outerRadius * math.cos(angle),
          center.dy + outerRadius * math.sin(angle),
        ),
        rayPaint,
      );
    }

    final bodyPaint = Paint()..color = color;
    canvas.drawCircle(center, radius, bodyPaint);

    final blushPaint = Paint()..color = GardenColors.softPink.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.5, center.dy + radius * 0.15),
        width: radius * 0.4,
        height: radius * 0.25,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.5, center.dy + radius * 0.15),
        width: radius * 0.4,
        height: radius * 0.25,
      ),
      blushPaint,
    );

    final eyePaint = Paint()..color = GardenColors.mintGreenDark;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.1),
      radius * 0.12,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.1),
      radius * 0.12,
      eyePaint,
    );

    final smilePaint = Paint()
      ..color = GardenColors.mintGreenDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.12
      ..strokeCap = StrokeCap.round;

    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.1),
        width: radius * 0.5,
        height: radius * 0.4,
      ),
      0.2,
      math.pi - 0.4,
    );
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _SunlightPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteSeedling extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteSeedling({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SeedlingPainter(color ?? GardenColors.mintGreen),
      ),
    );
  }
}

class _SeedlingPainter extends CustomPainter {
  final Color color;
  _SeedlingPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final potPaint = Paint()..color = const Color(0xFFE8C9A0);
    final potPath = Path();
    potPath.moveTo(w * 0.25, h * 0.7);
    potPath.lineTo(w * 0.3, h * 0.95);
    potPath.lineTo(w * 0.7, h * 0.95);
    potPath.lineTo(w * 0.75, h * 0.7);
    potPath.close();
    canvas.drawPath(potPath, potPaint);


    final rimPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.65, w * 0.56, h * 0.1),
        Radius.circular(w * 0.03),
      ),
      rimPaint,
    );


    final soilPaint = Paint()..color = const Color(0xFFB8956E);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.42, height: h * 0.08),
      soilPaint,
    );


    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.07
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stemPath = Path();
    stemPath.moveTo(w * 0.5, h * 0.68);
    stemPath.quadraticBezierTo(w * 0.48, h * 0.5, w * 0.5, h * 0.38);
    canvas.drawPath(stemPath, stemPaint);


    final leafPaint = Paint()..color = color;
    final leftLeaf = Path();
    leftLeaf.moveTo(w * 0.48, h * 0.4);
    leftLeaf.quadraticBezierTo(w * 0.2, h * 0.35, w * 0.22, h * 0.2);
    leftLeaf.quadraticBezierTo(w * 0.35, h * 0.22, w * 0.48, h * 0.4);
    canvas.drawPath(leftLeaf, leafPaint);


    final rightLeaf = Path();
    rightLeaf.moveTo(w * 0.52, h * 0.4);
    rightLeaf.quadraticBezierTo(w * 0.8, h * 0.35, w * 0.78, h * 0.2);
    rightLeaf.quadraticBezierTo(w * 0.65, h * 0.22, w * 0.52, h * 0.4);
    canvas.drawPath(rightLeaf, leafPaint);


    final veinPaint = Paint()
      ..color = GardenColors.leafGreen.withValues(alpha: 0.5)
      ..strokeWidth = w * 0.02
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, h * 0.28), Offset(w * 0.46, h * 0.38), veinPaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.28), Offset(w * 0.54, h * 0.38), veinPaint);


    final dewPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.32, h * 0.28), w * 0.035, dewPaint);
  }

  @override
  bool shouldRepaint(covariant _SeedlingPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteLeaves extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteLeaves({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LeavesPainter(color ?? GardenColors.mintGreen),
      ),
    );
  }
}

class _LeavesPainter extends CustomPainter {
  final Color color;
  _LeavesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;


    final potPaint = Paint()..color = const Color(0xFFE8C9A0);
    final potPath = Path();
    potPath.moveTo(w * 0.28, h * 0.72);
    potPath.lineTo(w * 0.32, h * 0.95);
    potPath.lineTo(w * 0.68, h * 0.95);
    potPath.lineTo(w * 0.72, h * 0.72);
    potPath.close();
    canvas.drawPath(potPath, potPaint);


    final rimPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.68, w * 0.5, h * 0.08),
        Radius.circular(w * 0.02),
      ),
      rimPaint,
    );

    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final mainStem = Path();
    mainStem.moveTo(w * 0.5, h * 0.7);
    mainStem.cubicTo(w * 0.48, h * 0.55, w * 0.52, h * 0.4, w * 0.5, h * 0.25);
    canvas.drawPath(mainStem, stemPaint);


    final branchPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branch1 = Path();
    branch1.moveTo(w * 0.5, h * 0.5);
    branch1.quadraticBezierTo(w * 0.35, h * 0.45, w * 0.25, h * 0.38);
    canvas.drawPath(branch1, branchPaint);


    final branch2 = Path();
    branch2.moveTo(w * 0.5, h * 0.4);
    branch2.quadraticBezierTo(w * 0.65, h * 0.35, w * 0.78, h * 0.32);
    canvas.drawPath(branch2, branchPaint);

    final leafPaint = Paint()..color = color;

    _drawLeaf(canvas, Offset(w * 0.5, h * 0.25), w * 0.22, -0.2, leafPaint);
    _drawLeaf(canvas, Offset(w * 0.42, h * 0.18), w * 0.16, -0.8, leafPaint);
    _drawLeaf(canvas, Offset(w * 0.58, h * 0.18), w * 0.16, 0.8, leafPaint);


    _drawLeaf(canvas, Offset(w * 0.25, h * 0.38), w * 0.15, -1.2, leafPaint);
    _drawLeaf(canvas, Offset(w * 0.78, h * 0.32), w * 0.14, 1.0, leafPaint);


    final dewPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.48, h * 0.22), w * 0.03, dewPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.35), w * 0.025, dewPaint);
  }

  void _drawLeaf(Canvas canvas, Offset tip, double length, double angle, Paint paint) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);

    final leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(-length * 0.4, length * 0.5, 0, length);
    leaf.quadraticBezierTo(length * 0.4, length * 0.5, 0, 0);
    canvas.drawPath(leaf, paint);

    // 叶脉
    final veinPaint = Paint()
      ..color = GardenColors.leafGreen.withValues(alpha: 0.4)
      ..strokeWidth = length * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, length * 0.15), Offset(0, length * 0.8), veinPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeavesPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteFlower extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteFlower({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FlowerPainter(color ?? GardenColors.lavender),
      ),
    );
  }
}

class _FlowerPainter extends CustomPainter {
  final Color color;
  _FlowerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flowerCenter = Offset(w * 0.5, h * 0.35);
    final petalRadius = w * 0.15;


    final potPaint = Paint()..color = const Color(0xFFE8C9A0);
    final potPath = Path();
    potPath.moveTo(w * 0.3, h * 0.75);
    potPath.lineTo(w * 0.35, h * 0.95);
    potPath.lineTo(w * 0.65, h * 0.95);
    potPath.lineTo(w * 0.7, h * 0.75);
    potPath.close();
    canvas.drawPath(potPath, potPaint);


    final rimPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.27, h * 0.71, w * 0.46, h * 0.07),
        Radius.circular(w * 0.02),
      ),
      rimPaint,
    );


    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.5, h * 0.5),
      Offset(w * 0.5, h * 0.73),
      stemPaint,
    );


    final leafPaint = Paint()..color = GardenColors.leafGreen;


    canvas.save();
    canvas.translate(w * 0.5, h * 0.62);
    canvas.rotate(-0.6);
    final leftLeaf = Path();
    leftLeaf.moveTo(0, 0);
    leftLeaf.quadraticBezierTo(-w * 0.12, -h * 0.08, -w * 0.05, -h * 0.15);
    leftLeaf.quadraticBezierTo(-w * 0.02, -h * 0.08, 0, 0);
    canvas.drawPath(leftLeaf, leafPaint);
    canvas.restore();


    canvas.save();
    canvas.translate(w * 0.5, h * 0.58);
    canvas.rotate(0.6);
    final rightLeaf = Path();
    rightLeaf.moveTo(0, 0);
    rightLeaf.quadraticBezierTo(w * 0.12, -h * 0.08, w * 0.05, -h * 0.15);
    rightLeaf.quadraticBezierTo(w * 0.02, -h * 0.08, 0, 0);
    canvas.drawPath(rightLeaf, leafPaint);
    canvas.restore();


    final petalPaint = Paint()..color = color;
    final petalHighlight = Paint()..color = Colors.white.withValues(alpha: 0.3);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final petalCenter = Offset(
        flowerCenter.dx + petalRadius * 1.15 * math.cos(angle),
        flowerCenter.dy + petalRadius * 1.15 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, petalRadius, petalPaint);

      canvas.drawCircle(
        Offset(petalCenter.dx - petalRadius * 0.25, petalCenter.dy - petalRadius * 0.25),
        petalRadius * 0.35,
        petalHighlight,
      );
    }


    final corePaint = Paint()..color = GardenColors.softYellow;
    canvas.drawCircle(flowerCenter, petalRadius * 0.7, corePaint);


    final coreDetail = Paint()..color = GardenColors.softOrange;
    canvas.drawCircle(flowerCenter, petalRadius * 0.25, coreDetail);
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter oldDelegate) =>
      oldDelegate.color != color;
}

class CuteBigFlower extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteBigFlower({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BigFlowerPainter(color ?? GardenColors.softPink),
      ),
    );
  }
}

class _BigFlowerPainter extends CustomPainter {
  final Color color;
  _BigFlowerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flowerCenter = Offset(w * 0.5, h * 0.38);
    final petalSize = w * 0.18;


    final potPaint = Paint()..color = const Color(0xFFE8C9A0);
    final potPath = Path();
    potPath.moveTo(w * 0.32, h * 0.78);
    potPath.quadraticBezierTo(w * 0.35, h * 0.95, w * 0.5, h * 0.95);
    potPath.quadraticBezierTo(w * 0.65, h * 0.95, w * 0.68, h * 0.78);
    potPath.close();
    canvas.drawPath(potPath, potPaint);


    final rimPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.73, w * 0.44, h * 0.07),
        Radius.circular(w * 0.02),
      ),
      rimPaint,
    );


    final patternPaint = Paint()
      ..color = const Color(0xFFD4A574).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.015;
    canvas.drawLine(Offset(w * 0.4, h * 0.82), Offset(w * 0.4, h * 0.9), patternPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.82), Offset(w * 0.5, h * 0.92), patternPaint);
    canvas.drawLine(Offset(w * 0.6, h * 0.82), Offset(w * 0.6, h * 0.9), patternPaint);


    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.5, h * 0.75), stemPaint);


    final leafPaint = Paint()..color = GardenColors.leafGreen;
    _drawPrettyLeaf(canvas, Offset(w * 0.5, h * 0.65), w * 0.18, -0.8, leafPaint);
    _drawPrettyLeaf(canvas, Offset(w * 0.5, h * 0.7), w * 0.15, 0.7, leafPaint);


    final outerPetalPaint = Paint()..color = color.withValues(alpha: 0.7);
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + 0.2;
      _drawPetal(canvas, flowerCenter, petalSize * 1.3, angle, outerPetalPaint);
    }


    final innerPetalPaint = Paint()..color = color;
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      _drawPetal(canvas, flowerCenter, petalSize, angle, innerPetalPaint);
    }


    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) - 0.3;
      final pos = Offset(
        flowerCenter.dx + petalSize * 0.7 * math.cos(angle),
        flowerCenter.dy + petalSize * 0.7 * math.sin(angle),
      );
      canvas.drawCircle(pos, petalSize * 0.2, highlightPaint);
    }


    final core1 = Paint()..color = GardenColors.softYellow;
    canvas.drawCircle(flowerCenter, petalSize * 0.55, core1);

    final core2 = Paint()..color = GardenColors.softOrange;
    canvas.drawCircle(flowerCenter, petalSize * 0.35, core2);


    final dotPaint = Paint()..color = const Color(0xFFE8A060);
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      final pos = Offset(
        flowerCenter.dx + petalSize * 0.2 * math.cos(angle),
        flowerCenter.dy + petalSize * 0.2 * math.sin(angle),
      );
      canvas.drawCircle(pos, petalSize * 0.08, dotPaint);
    }
  }

  void _drawPetal(Canvas canvas, Offset center, double size, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final petal = Path();
    petal.moveTo(0, -size * 0.3);
    petal.quadraticBezierTo(-size * 0.35, -size * 0.8, 0, -size * 1.2);
    petal.quadraticBezierTo(size * 0.35, -size * 0.8, 0, -size * 0.3);
    canvas.drawPath(petal, paint);

    canvas.restore();
  }

  void _drawPrettyLeaf(Canvas canvas, Offset base, double length, double angle, Paint paint) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(-length * 0.4, -length * 0.5, 0, -length);
    leaf.quadraticBezierTo(length * 0.4, -length * 0.5, 0, 0);
    canvas.drawPath(leaf, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BigFlowerPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteSunflower extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteSunflower({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SunflowerPainter(color ?? GardenColors.softYellow),
      ),
    );
  }
}

class _SunflowerPainter extends CustomPainter {
  final Color color;
  _SunflowerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final flowerCenter = Offset(w * 0.5, h * 0.35);
    final petalLength = w * 0.18;

    final potPaint = Paint()..color = const Color(0xFFE8C9A0);
    final potPath = Path();
    potPath.moveTo(w * 0.3, h * 0.78);
    potPath.quadraticBezierTo(w * 0.32, h * 0.95, w * 0.5, h * 0.95);
    potPath.quadraticBezierTo(w * 0.68, h * 0.95, w * 0.7, h * 0.78);
    potPath.close();
    canvas.drawPath(potPath, potPaint);

    final rimPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.73, w * 0.48, h * 0.08),
        Radius.circular(w * 0.02),
      ),
      rimPaint,
    );

    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stem = Path();
    stem.moveTo(w * 0.5, h * 0.52);
    stem.quadraticBezierTo(w * 0.48, h * 0.62, w * 0.5, h * 0.75);
    canvas.drawPath(stem, stemPaint);

    final leafPaint = Paint()..color = GardenColors.leafGreen;
    _drawSunflowerLeaf(canvas, Offset(w * 0.5, h * 0.6), w * 0.22, -0.9, leafPaint);
    _drawSunflowerLeaf(canvas, Offset(w * 0.5, h * 0.68), w * 0.2, 0.85, leafPaint);

    final outerPetalPaint = Paint()..color = color.withValues(alpha: 0.75);
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) + 0.1;
      _drawSunflowerPetal(canvas, flowerCenter, petalLength * 1.15, angle, outerPetalPaint);
    }


    final innerPetalPaint = Paint()..color = color;
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8);
      _drawSunflowerPetal(canvas, flowerCenter, petalLength * 0.9, angle, innerPetalPaint);
    }

    final diskPaint = Paint()..color = const Color(0xFFB8956E);
    canvas.drawCircle(flowerCenter, petalLength * 0.75, diskPaint);

    final innerDisk = Paint()..color = const Color(0xFF8B6E4E);
    canvas.drawCircle(flowerCenter, petalLength * 0.55, innerDisk);

    final seedPaint = Paint()..color = const Color(0xFF5D4037);
    for (int ring = 0; ring < 3; ring++) {
      final radius = petalLength * (0.15 + ring * 0.15);
      final count = 6 + ring * 3;
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * math.pi / count) + ring * 0.3;
        final pos = Offset(
          flowerCenter.dx + radius * math.cos(angle),
          flowerCenter.dy + radius * math.sin(angle),
        );
        canvas.drawCircle(pos, petalLength * 0.06, seedPaint);
      }
    }
  }

  void _drawSunflowerPetal(Canvas canvas, Offset center, double length, double angle, Paint paint) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final petal = Path();
    petal.moveTo(0, -length * 0.4);
    petal.quadraticBezierTo(-length * 0.2, -length * 0.9, 0, -length * 1.3);
    petal.quadraticBezierTo(length * 0.2, -length * 0.9, 0, -length * 0.4);
    canvas.drawPath(petal, paint);

    canvas.restore();
  }

  void _drawSunflowerLeaf(Canvas canvas, Offset base, double length, double angle, Paint paint) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final leaf = Path();
    leaf.moveTo(0, 0);
    leaf.quadraticBezierTo(-length * 0.5, -length * 0.4, -length * 0.2, -length);
    leaf.quadraticBezierTo(0, -length * 0.7, length * 0.2, -length);
    leaf.quadraticBezierTo(length * 0.5, -length * 0.4, 0, 0);
    canvas.drawPath(leaf, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SunflowerPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteTree extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteTree({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TreePainter(color ?? GardenColors.mintGreen),
      ),
    );
  }
}

class _TreePainter extends CustomPainter {
  final Color color;
  _TreePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final grassPaint = Paint()..color = GardenColors.mintGreenLight;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.94), width: w * 0.85, height: h * 0.12),
      grassPaint,
    );


    final trunkPaint = Paint()..color = const Color(0xFFB8956E);
    final trunk = Path();
    trunk.moveTo(w * 0.4, h * 0.55);
    trunk.quadraticBezierTo(w * 0.38, h * 0.7, w * 0.35, h * 0.9);
    trunk.lineTo(w * 0.65, h * 0.9);
    trunk.quadraticBezierTo(w * 0.62, h * 0.7, w * 0.6, h * 0.55);
    trunk.close();
    canvas.drawPath(trunk, trunkPaint);

    final barkPaint = Paint()
      ..color = const Color(0xFF8B6E4E).withValues(alpha: 0.5)
      ..strokeWidth = w * 0.015
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.45, h * 0.6), Offset(w * 0.42, h * 0.8), barkPaint);
    canvas.drawLine(Offset(w * 0.52, h * 0.62), Offset(w * 0.5, h * 0.85), barkPaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.6), Offset(w * 0.56, h * 0.78), barkPaint);

    final branchPaint = Paint()
      ..color = const Color(0xFFB8956E)
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.45, h * 0.55), Offset(w * 0.25, h * 0.42), branchPaint);
    canvas.drawLine(Offset(w * 0.55, h * 0.55), Offset(w * 0.78, h * 0.4), branchPaint);
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.5, h * 0.35), branchPaint);


    final foliageDark = Paint()..color = GardenColors.leafGreen;
    final foliageMain = Paint()..color = color;
    final foliageLight = Paint()..color = color.withValues(alpha: 0.85);


    canvas.drawCircle(Offset(w * 0.22, h * 0.45), w * 0.2, foliageDark);
    canvas.drawCircle(Offset(w * 0.78, h * 0.43), w * 0.2, foliageDark);
    canvas.drawCircle(Offset(w * 0.35, h * 0.52), w * 0.18, foliageDark);
    canvas.drawCircle(Offset(w * 0.65, h * 0.5), w * 0.18, foliageDark);


    canvas.drawCircle(Offset(w * 0.3, h * 0.38), w * 0.22, foliageMain);
    canvas.drawCircle(Offset(w * 0.7, h * 0.36), w * 0.22, foliageMain);
    canvas.drawCircle(Offset(w * 0.5, h * 0.42), w * 0.23, foliageMain);


    canvas.drawCircle(Offset(w * 0.38, h * 0.28), w * 0.2, foliageLight);
    canvas.drawCircle(Offset(w * 0.62, h * 0.26), w * 0.2, foliageLight);
    canvas.drawCircle(Offset(w * 0.5, h * 0.22), w * 0.22, foliageLight);

    // 小花
    final flowerPaint = Paint()..color = GardenColors.lavender;
    final flowerPositions = [
      Offset(w * 0.28, h * 0.32),
      Offset(w * 0.55, h * 0.25),
      Offset(w * 0.72, h * 0.35),
      Offset(w * 0.4, h * 0.45),
      Offset(w * 0.65, h * 0.42),
    ];
    for (final pos in flowerPositions) {
      _drawTinyFlower(canvas, pos, w * 0.04, flowerPaint);
    }

    final fruitPaint = Paint()..color = GardenColors.softPink;
    canvas.drawCircle(Offset(w * 0.35, h * 0.38), w * 0.035, fruitPaint);
    canvas.drawCircle(Offset(w * 0.6, h * 0.32), w * 0.035, fruitPaint);
    canvas.drawCircle(Offset(w * 0.48, h * 0.3), w * 0.03, fruitPaint);


    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(w * 0.42, h * 0.2), w * 0.06, highlightPaint);
    canvas.drawCircle(Offset(w * 0.32, h * 0.35), w * 0.04, highlightPaint);
  }

  void _drawTinyFlower(Canvas canvas, Offset center, double size, Paint paint) {

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final petalCenter = Offset(
        center.dx + size * 0.7 * math.cos(angle),
        center.dy + size * 0.7 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, size * 0.5, paint);
    }

    canvas.drawCircle(center, size * 0.35, Paint()..color = GardenColors.softYellow);
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteSparkle extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteSparkle({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SparklePainter(color ?? GardenColors.softYellow),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;
  _SparklePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint = Paint()..color = color;

    _drawFourPointStar(canvas, Offset(w * 0.5, h * 0.5), w * 0.35, paint);

    final smallPaint = Paint()..color = color.withValues(alpha: 0.6);
    _drawFourPointStar(canvas, Offset(w * 0.2, h * 0.22), w * 0.12, smallPaint);
    _drawFourPointStar(canvas, Offset(w * 0.82, h * 0.3), w * 0.1, smallPaint);
    _drawFourPointStar(canvas, Offset(w * 0.78, h * 0.78), w * 0.08, smallPaint);
  }

  void _drawFourPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();

    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.25, center.dy - radius * 0.25);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.25, center.dy + radius * 0.25);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.25, center.dy + radius * 0.25);
    path.lineTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.25, center.dy - radius * 0.25);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) =>
      oldDelegate.color != color;
}

class CuteTrophy extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteTrophy({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrophyPainter(color ?? GardenColors.softYellow),
      ),
    );
  }
}

class _TrophyPainter extends CustomPainter {
  final Color color;
  _TrophyPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()..color = color;


    final cupPath = Path();
    cupPath.moveTo(w * 0.2, h * 0.12);
    cupPath.lineTo(w * 0.8, h * 0.12);
    cupPath.lineTo(w * 0.75, h * 0.45);
    cupPath.quadraticBezierTo(w * 0.5, h * 0.6, w * 0.25, h * 0.45);
    cupPath.close();
    canvas.drawPath(cupPath, bodyPaint);

    final handlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.12, h * 0.28), width: w * 0.18, height: h * 0.2),
      0.5,
      2,
      false,
      handlePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.88, h * 0.28), width: w * 0.18, height: h * 0.2),
      0.6,
      -2,
      false,
      handlePaint,
    );


    final basePaint = Paint()..color = GardenColors.creamDark;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.58), width: w * 0.15, height: h * 0.1),
        Radius.circular(w * 0.02),
      ),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.25, height: h * 0.12),
        Radius.circular(w * 0.03),
      ),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.88), width: w * 0.45, height: h * 0.15),
        Radius.circular(w * 0.05),
      ),
      basePaint,
    );

    // 星星
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    _drawTinyStar(canvas, Offset(w * 0.5, h * 0.3), w * 0.08, starPaint);
  }

  void _drawTinyStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy + radius);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrophyPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteStar extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteStar({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _StarPainter(color ?? GardenColors.softYellow),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45;
    final innerRadius = size.width * 0.2;

    final paint = Paint()..color = color;

    final path = Path();

    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 4 * math.pi / 5) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 5;

      final outerPoint = Offset(
        center.dx + outerRadius * math.cos(outerAngle),
        center.dy + outerRadius * math.sin(outerAngle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(innerAngle),
        center.dy + innerRadius * math.sin(innerAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) =>
      oldDelegate.color != color;
}


class CuteCelebration extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteCelebration({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CelebrationPainter(color ?? GardenColors.lavender),
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final Color color;
  _CelebrationPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final conePaint = Paint()..color = color;
    final cone = Path();
    cone.moveTo(w * 0.3, h * 0.15);
    cone.lineTo(w * 0.85, h * 0.85);
    cone.lineTo(w * 0.15, h * 0.85);
    cone.close();
    canvas.drawPath(cone, conePaint);

    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.32, h * 0.75), stripePaint);
    canvas.drawLine(Offset(w * 0.52, h * 0.45), Offset(w * 0.55, h * 0.75), stripePaint);

    final confettiColors = [
      GardenColors.softBlue,
      GardenColors.softYellow,
      GardenColors.mintGreen,
      GardenColors.softPink,
      GardenColors.lavenderLight,
    ];

    final positions = [
      Offset(w * 0.12, h * 0.2),
      Offset(w * 0.78, h * 0.12),
      Offset(w * 0.9, h * 0.4),
      Offset(w * 0.08, h * 0.5),
      Offset(w * 0.88, h * 0.6),
    ];

    for (int i = 0; i < positions.length; i++) {
      final paint = Paint()..color = confettiColors[i];

      if (i % 2 == 0) {
        canvas.drawCircle(positions[i], w * 0.05, paint);
      } else {
        canvas.save();
        canvas.translate(positions[i].dx, positions[i].dy);
        canvas.rotate(i * 0.5);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w * 0.1, height: w * 0.05),
            Radius.circular(w * 0.02),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PlantLevelIcon extends StatelessWidget {
  final int level;
  final double size;
  final Color? color;

  const PlantLevelIcon({
    super.key,
    required this.level,
    this.size = 80,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (level <= 2) {
      return CuteSeedling(size: size, color: color);
    } else if (level <= 4) {
      return CuteLeaves(size: size, color: color);
    } else if (level <= 6) {
      return CuteFlower(size: size, color: color);
    } else if (level <= 8) {
      return CuteBigFlower(size: size, color: color);
    } else if (level <= 9) {
      return CuteSunflower(size: size, color: color);
    } else {
      return CuteTree(size: size, color: color);
    }
  }
}

class AnimatedResourceIcon extends StatefulWidget {
  final String type;
  final double size;

  const AnimatedResourceIcon({
    super.key,
    required this.type,
    this.size = 28,
  });

  @override
  State<AnimatedResourceIcon> createState() => _AnimatedResourceIconState();
}

class _AnimatedResourceIconState extends State<AnimatedResourceIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _scaleAnimation,
      builder: (context, _) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.type == 'water'
              ? CuteWaterDrop(size: widget.size)
              : CuteSunlight(size: widget.size),
        );
      },
    );
  }
}

class CuteHabitIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteHabitIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HabitIconPainter(
          color ?? (isActive ? GardenColors.mintGreen : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _HabitIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _HabitIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stemPaint = Paint()
      ..color = isActive ? GardenColors.leafGreen : color.withValues(alpha: 0.7)
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.9), Offset(w * 0.5, h * 0.5), stemPaint);

    final leafPaint = Paint()..color = color;


    final leftLeaf = Path();
    leftLeaf.moveTo(w * 0.48, h * 0.52);
    leftLeaf.quadraticBezierTo(w * 0.15, h * 0.4, w * 0.2, h * 0.2);
    leftLeaf.quadraticBezierTo(w * 0.35, h * 0.3, w * 0.48, h * 0.52);
    canvas.drawPath(leftLeaf, leafPaint);


    final rightLeaf = Path();
    rightLeaf.moveTo(w * 0.52, h * 0.52);
    rightLeaf.quadraticBezierTo(w * 0.85, h * 0.4, w * 0.8, h * 0.2);
    rightLeaf.quadraticBezierTo(w * 0.65, h * 0.3, w * 0.52, h * 0.52);
    canvas.drawPath(rightLeaf, leafPaint);


    if (isActive) {
      final dotPaint = Paint()..color = GardenColors.softYellow;
      canvas.drawCircle(Offset(w * 0.3, h * 0.3), w * 0.06, dotPaint);
      canvas.drawCircle(Offset(w * 0.72, h * 0.28), w * 0.05, dotPaint);
    }
  }


  @override
  bool shouldRepaint(covariant _HabitIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}


class CuteMoodIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteMoodIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoodIconPainter(
          color ?? (isActive ? GardenColors.lavender : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _MoodIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _MoodIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bookPaint = Paint()..color = color;
    final bookRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.7, h * 0.8),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(bookRect, bookPaint);

    final spinePaint = Paint()..color = isActive ? GardenColors.lavenderDark : color.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.1, w * 0.12, h * 0.8),
        Radius.circular(w * 0.08),
      ),
      spinePaint,
    );
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = w * 0.03;
    for (int i = 0; i < 3; i++) {
      final y = h * (0.3 + i * 0.2);
      canvas.drawLine(Offset(w * 0.35, y), Offset(w * 0.75, y), linePaint);
    }

    if (isActive) {
      final heartPaint = Paint()..color = GardenColors.softPink;
      _drawHeart(canvas, Offset(w * 0.55, h * 0.5), w * 0.12, heartPaint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.5, center.dy - size * 0.2,
      center.dx - size * 0.5, center.dy - size * 0.5,
      center.dx, center.dy - size * 0.2,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size * 0.5,
      center.dx + size * 0.5, center.dy - size * 0.2,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MoodIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}

class CuteGardenIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteGardenIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GardenIconPainter(
          color ?? (isActive ? GardenColors.softPink : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _GardenIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _GardenIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.4);
    final petalR = w * 0.15;

    final stemPaint = Paint()
      ..color = GardenColors.leafGreen
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.5, h * 0.55), Offset(w * 0.5, h * 0.9), stemPaint);

    final leafPaint = Paint()..color = GardenColors.mintGreen;
    canvas.save();
    canvas.translate(w * 0.5, h * 0.72);
    canvas.rotate(0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.2, height: w * 0.1), leafPaint);
    canvas.restore();

    final petalPaint = Paint()..color = color;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final petalCenter = Offset(
        center.dx + petalR * 1.1 * math.cos(angle),
        center.dy + petalR * 1.1 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, petalR, petalPaint);
    }

    final corePaint = Paint()..color = GardenColors.softYellow;
    canvas.drawCircle(center, petalR * 0.6, corePaint);

    if (isActive) {
      final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(center.dx - petalR * 0.2, center.dy - petalR * 0.2), petalR * 0.25, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GardenIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}

class CuteKindnessIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteKindnessIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _KindnessIconPainter(
          color ?? (isActive ? GardenColors.softPink : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _KindnessIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _KindnessIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    final heartPaint = Paint()..color = color;
    final heartPath = Path();
    heartPath.moveTo(center.dx, h * 0.85);
    heartPath.cubicTo(
      w * 0.05, h * 0.5,
      w * 0.05, h * 0.2,
      center.dx, h * 0.35,
    );
    heartPath.cubicTo(
      w * 0.95, h * 0.2,
      w * 0.95, h * 0.5,
      center.dx, h * 0.85,
    );
    canvas.drawPath(heartPath, heartPaint);

    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(w * 0.35, h * 0.38), w * 0.1, highlightPaint);

    if (isActive) {
      final sparkPaint = Paint()..color = GardenColors.softYellow;
      canvas.drawCircle(Offset(w * 0.8, h * 0.25), w * 0.06, sparkPaint);
      canvas.drawCircle(Offset(w * 0.18, h * 0.22), w * 0.04, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KindnessIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}

class CuteFernIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteFernIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FernIconPainter(
          color ?? (isActive ? GardenColors.mintGreen : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _FernIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _FernIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()..color = color;
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.5, h * 0.15);
    bodyPath.quadraticBezierTo(w * 0.85, h * 0.2, w * 0.8, h * 0.5);
    bodyPath.quadraticBezierTo(w * 0.75, h * 0.8, w * 0.5, h * 0.85);
    bodyPath.quadraticBezierTo(w * 0.25, h * 0.8, w * 0.2, h * 0.5);
    bodyPath.quadraticBezierTo(w * 0.15, h * 0.2, w * 0.5, h * 0.15);
    canvas.drawPath(bodyPath, bodyPaint);

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h * 0.45), w * 0.1, eyePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.45), w * 0.1, eyePaint);

    final pupilPaint = Paint()..color = GardenColors.textDark;
    canvas.drawCircle(Offset(w * 0.4, h * 0.46), w * 0.05, pupilPaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.46), w * 0.05, pupilPaint);


    final smilePaint = Paint()
      ..color = GardenColors.textDark
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final smilePath = Path();
    smilePath.addArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.6), width: w * 0.25, height: w * 0.15),
      0.2, math.pi - 0.4,
    );
    canvas.drawPath(smilePath, smilePaint);

    if (isActive) {
      final blushPaint = Paint()..color = GardenColors.softPink.withValues(alpha: 0.5);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.25, h * 0.55), width: w * 0.12, height: w * 0.08), blushPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.75, h * 0.55), width: w * 0.12, height: w * 0.08), blushPaint);
    }

    final leafPaint = Paint()..color = GardenColors.leafGreen;
    final leafPath = Path();
    leafPath.moveTo(w * 0.5, h * 0.15);
    leafPath.quadraticBezierTo(w * 0.4, h * 0.0, w * 0.5, h * 0.0);
    leafPath.quadraticBezierTo(w * 0.6, h * 0.0, w * 0.5, h * 0.15);
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(covariant _FernIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}
class CuteJourneyIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool isActive;

  const CuteJourneyIcon({
    super.key,
    this.size = 24,
    this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _JourneyIconPainter(
          color ?? (isActive ? GardenColors.softBlue : GardenColors.textMedium),
          isActive,
        ),
      ),
    );
  }
}

class _JourneyIconPainter extends CustomPainter {
  final Color color;
  final bool isActive;
  _JourneyIconPainter(this.color, this.isActive);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final barPaint = Paint()..color = color;
    final bar1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.55, w * 0.2, h * 0.35),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bar1, barPaint);

    final bar2Paint = Paint()..color = isActive ? GardenColors.mintGreen : color.withValues(alpha: 0.7);
    final bar2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.4, h * 0.35, w * 0.2, h * 0.55),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bar2, bar2Paint);

    final bar3Paint = Paint()..color = isActive ? GardenColors.softYellow : color.withValues(alpha: 0.5);
    final bar3 = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.68, h * 0.2, w * 0.2, h * 0.7),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bar3, bar3Paint);

    if (isActive) {
      final starPaint = Paint()..color = GardenColors.softYellow;
      canvas.drawCircle(Offset(w * 0.78, h * 0.12), w * 0.06, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JourneyIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isActive != isActive;
}


class CuteMoodEmoji extends StatelessWidget {
  final String mood;
  final double size;

  const CuteMoodEmoji({
    super.key,
    required this.mood,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoodEmojiPainter(mood),
      ),
    );
  }
}

class _MoodEmojiPainter extends CustomPainter {
  final String mood;
  _MoodEmojiPainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w * 0.42;

    final faceColor = _getMoodColor();

    final facePaint = Paint()..color = faceColor;
    canvas.drawCircle(center, radius, facePaint);

    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF4A4A4A);

    switch (mood.toLowerCase()) {
      case 'happy':
        _drawHappyEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawSmile(canvas, w, h, true);
        _drawBlush(canvas, w, h);
        break;
      case 'calm':
        _drawNormalEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawSmile(canvas, w, h, false);
        break;
      case 'sad':
        _drawSadEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawFrown(canvas, w, h);
        break;
      case 'anxious':
        _drawWorriedEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawWavyMouth(canvas, w, h);
        break;
      case 'stressed':
        _drawStressedEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawTightMouth(canvas, w, h);
        break;
      case 'angry':
        _drawAngryEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawFrown(canvas, w, h);
        break;
      case 'tired':
        _drawTiredEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawTiredMouth(canvas, w, h);
        break;
      case 'hopeful':
        _drawSparklyEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawSmile(canvas, w, h, true);
        break;
      default:
        _drawNormalEyes(canvas, w, h, eyePaint, pupilPaint);
        _drawNeutralMouth(canvas, w, h);
    }
  }

  Color _getMoodColor() {
    switch (mood.toLowerCase()) {
      case 'happy': return const Color(0xFFFFE082);
      case 'calm': return const Color(0xFFA5D6A7);
      case 'sad': return const Color(0xFF90CAF9);
      case 'anxious': return const Color(0xFFCE93D8);
      case 'stressed': return const Color(0xFFFFCC80);
      case 'angry': return const Color(0xFFEF9A9A);
      case 'tired': return const Color(0xFFB0BEC5);
      case 'hopeful': return const Color(0xFF80DEEA);
      case 'lonely': return const Color(0xFF9FA8DA);
      default: return const Color(0xFFE0E0E0);
    }
  }

  void _drawHappyEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    final arcPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.04
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.42), width: w * 0.18, height: w * 0.12),
      math.pi, math.pi, false, arcPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.65, h * 0.42), width: w * 0.18, height: w * 0.12),
      math.pi, math.pi, false, arcPaint,
    );
  }

  void _drawNormalEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.08, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.08, eyePaint);
    canvas.drawCircle(Offset(w * 0.36, h * 0.43), w * 0.045, pupilPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.43), w * 0.045, pupilPaint);
  }

  void _drawSadEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.08, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.08, eyePaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.44), w * 0.045, pupilPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.44), w * 0.045, pupilPaint);

    final browPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.25, h * 0.32), Offset(w * 0.4, h * 0.35), browPaint);
    canvas.drawLine(Offset(w * 0.75, h * 0.32), Offset(w * 0.6, h * 0.35), browPaint);
  }

  void _drawWorriedEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.085, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.085, eyePaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.04, pupilPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.04, pupilPaint);

    final browPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.28, h * 0.3), Offset(w * 0.42, h * 0.33), browPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.3), Offset(w * 0.58, h * 0.33), browPaint);
  }

  void _drawStressedEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    final xPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.3, h * 0.38), Offset(w * 0.4, h * 0.48), xPaint);
    canvas.drawLine(Offset(w * 0.4, h * 0.38), Offset(w * 0.3, h * 0.48), xPaint);
    canvas.drawLine(Offset(w * 0.6, h * 0.38), Offset(w * 0.7, h * 0.48), xPaint);
    canvas.drawLine(Offset(w * 0.7, h * 0.38), Offset(w * 0.6, h * 0.48), xPaint);
  }

  void _drawAngryEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.07, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.07, eyePaint);
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.04, pupilPaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.04, pupilPaint);

    final browPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.25, h * 0.35), Offset(w * 0.42, h * 0.3), browPaint);
    canvas.drawLine(Offset(w * 0.75, h * 0.35), Offset(w * 0.58, h * 0.3), browPaint);
  }

  void _drawTiredEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    final arcPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.04
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.42), width: w * 0.16, height: w * 0.08),
      0, math.pi, false, arcPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.65, h * 0.42), width: w * 0.16, height: w * 0.08),
      0, math.pi, false, arcPaint,
    );
  }

  void _drawSparklyEyes(Canvas canvas, double w, double h, Paint eyePaint, Paint pupilPaint) {
    canvas.drawCircle(Offset(w * 0.35, h * 0.42), w * 0.09, eyePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.42), w * 0.09, eyePaint);
    canvas.drawCircle(Offset(w * 0.36, h * 0.42), w * 0.045, pupilPaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.42), w * 0.045, pupilPaint);

    final sparkPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.32, h * 0.39), w * 0.025, sparkPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.39), w * 0.025, sparkPaint);
  }

  void _drawSmile(Canvas canvas, double w, double h, bool big) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.62),
        width: big ? w * 0.35 : w * 0.25,
        height: big ? w * 0.2 : w * 0.12,
      ),
      0.2, math.pi - 0.4, false, mouthPaint,
    );
  }

  void _drawFrown(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.035
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.72), width: w * 0.25, height: w * 0.15),
      math.pi + 0.2, math.pi - 0.4, false, mouthPaint,
    );
  }

  void _drawWavyMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(w * 0.35, h * 0.65);
    path.quadraticBezierTo(w * 0.42, h * 0.7, w * 0.5, h * 0.65);
    path.quadraticBezierTo(w * 0.58, h * 0.6, w * 0.65, h * 0.65);
    canvas.drawPath(path, mouthPaint);
  }

  void _drawTightMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.38, h * 0.65), Offset(w * 0.62, h * 0.65), mouthPaint);
  }

  void _drawTiredMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.65), width: w * 0.15, height: w * 0.12),
      mouthPaint,
    );
  }

  void _drawNeutralMouth(Canvas canvas, double w, double h) {
    final mouthPaint = Paint()
      ..color = const Color(0xFF4A4A4A)
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.4, h * 0.65), Offset(w * 0.6, h * 0.65), mouthPaint);
  }

  void _drawBlush(Canvas canvas, double w, double h) {
    final blushPaint = Paint()..color = const Color(0xFFFFAB91).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.22, h * 0.52), width: w * 0.12, height: w * 0.08),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.78, h * 0.52), width: w * 0.12, height: w * 0.08),
      blushPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MoodEmojiPainter oldDelegate) =>
      oldDelegate.mood != mood;
}

// 習慣類別圖標

class CuteCategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final Color? color;

  const CuteCategoryIcon({
    super.key,
    required this.category,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CategoryIconPainter(category, color),
      ),
    );
  }
}

class _CategoryIconPainter extends CustomPainter {
  final String category;
  final Color? customColor;
  _CategoryIconPainter(this.category, this.customColor);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (category) {
      case 'Mindfulness':
        _drawMindfulnessIcon(canvas, w, h);
        break;
      case 'Exercise':
        _drawExerciseIcon(canvas, w, h);
        break;
      case 'Social':
        _drawSocialIcon(canvas, w, h);
        break;
      case 'Creative':
        _drawCreativeIcon(canvas, w, h);
        break;
      case 'Learning':
        _drawLearningIcon(canvas, w, h);
        break;
      case 'Self-Care':
      default:
        _drawSelfCareIcon(canvas, w, h);
        break;
    }
  }

  void _drawMindfulnessIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.lavender;
    final paint = Paint()..color = color;
    final center = Offset(w * 0.5, h * 0.55);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -w * 0.22), width: w * 0.2, height: w * 0.35),
        paint,
      );
      canvas.restore();
    }

    final centerPaint = Paint()..color = GardenColors.softYellow;
    canvas.drawCircle(center, w * 0.12, centerPaint);
  }

  void _drawExerciseIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.softOrange;
    final paint = Paint()..color = color;

    final barPaint = Paint()..color = GardenColors.textMedium;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.5, height: h * 0.12),
        Radius.circular(w * 0.03),
      ),
      barPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.25, w * 0.2, h * 0.5),
        Radius.circular(w * 0.06),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.7, h * 0.25, w * 0.2, h * 0.5),
        Radius.circular(w * 0.06),
      ),
      paint,
    );
  }

  void _drawSocialIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.softBlue;
    final paint = Paint()..color = color;

    canvas.drawCircle(Offset(w * 0.35, h * 0.3), w * 0.15, paint);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.35, h * 0.65), width: w * 0.3, height: w * 0.4),
      paint,
    );

    final paint2 = Paint()..color = GardenColors.mintGreen;
    canvas.drawCircle(Offset(w * 0.65, h * 0.3), w * 0.15, paint2);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.65, h * 0.65), width: w * 0.3, height: w * 0.4),
      paint2,
    );
  }

  void _drawCreativeIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.softPink;

    final palettePaint = Paint()..color = color;
    final palettePath = Path();
    palettePath.addOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.5), width: w * 0.8, height: h * 0.7));
    palettePath.addOval(Rect.fromCenter(center: Offset(w * 0.35, h * 0.5), width: w * 0.15, height: h * 0.2));
    palettePath.fillType = PathFillType.evenOdd;
    canvas.drawPath(palettePath, palettePaint);

    canvas.drawCircle(Offset(w * 0.55, h * 0.32), w * 0.08, Paint()..color = GardenColors.softYellow);
    canvas.drawCircle(Offset(w * 0.7, h * 0.45), w * 0.07, Paint()..color = GardenColors.softBlue);
    canvas.drawCircle(Offset(w * 0.65, h * 0.65), w * 0.08, Paint()..color = GardenColors.mintGreen);
    canvas.drawCircle(Offset(w * 0.45, h * 0.68), w * 0.06, Paint()..color = GardenColors.lavender);
  }

  void _drawLearningIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.softBlue;

    final bookPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.7),
        Radius.circular(w * 0.06),
      ),
      bookPaint,
    );

    final spinePaint = Paint()..color = GardenColors.softBlue.withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.12, h * 0.7),
        Radius.circular(w * 0.06),
      ),
      spinePaint,
    );

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = w * 0.025;
    canvas.drawLine(Offset(w * 0.35, h * 0.35), Offset(w * 0.75, h * 0.35), linePaint);
    canvas.drawLine(Offset(w * 0.35, h * 0.5), Offset(w * 0.75, h * 0.5), linePaint);
    canvas.drawLine(Offset(w * 0.35, h * 0.65), Offset(w * 0.65, h * 0.65), linePaint);
  }

  void _drawSelfCareIcon(Canvas canvas, double w, double h) {
    final color = customColor ?? GardenColors.mintGreen;

    final heartPaint = Paint()..color = color;
    final heartPath = Path();
    heartPath.moveTo(w * 0.5, h * 0.85);
    heartPath.cubicTo(w * 0.1, h * 0.5, w * 0.1, h * 0.2, w * 0.5, h * 0.35);
    heartPath.cubicTo(w * 0.9, h * 0.2, w * 0.9, h * 0.5, w * 0.5, h * 0.85);
    canvas.drawPath(heartPath, heartPaint);

    final leafPaint = Paint()..color = GardenColors.leafGreen;
    canvas.save();
    canvas.translate(w * 0.72, h * 0.22);
    canvas.rotate(0.5);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.18, height: w * 0.1), leafPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CategoryIconPainter oldDelegate) =>
      oldDelegate.category != category || oldDelegate.customColor != customColor;
}

// 工具方法 - 根据类型获取图标

class CuteNavIcon extends StatelessWidget {
  final String type;
  final double size;
  final bool isActive;

  const CuteNavIcon({
    super.key,
    required this.type,
    this.size = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'habits':
        return CuteHabitIcon(size: size, isActive: isActive);
      case 'mood':
        return CuteMoodIcon(size: size, isActive: isActive);
      case 'garden':
        return CuteGardenIcon(size: size, isActive: isActive);
      case 'kindness':
        return CuteKindnessIcon(size: size, isActive: isActive);
      case 'fern':
        return CuteFernIcon(size: size, isActive: isActive);
      case 'journey':
        return CuteJourneyIcon(size: size, isActive: isActive);
      default:
        return CuteHabitIcon(size: size, isActive: isActive);
    }
  }
}