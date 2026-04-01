// screens/welcome_back_screen.dart
// Thyme App Welcome Back Page - Cute Style Version
// Calm Gamification: No-guilt return screen

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/welcome_back_service.dart';
import '../utils/theme.dart';

class WelcomeBackScreen extends StatefulWidget {
  final int daysSinceLastVisit;
  final VoidCallback onContinue;

  const WelcomeBackScreen({
    Key? key,
    required this.daysSinceLastVisit,
    required this.onContinue,
  }) : super(key: key);

  @override
  State<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen>
    with TickerProviderStateMixin {
  final WelcomeBackService _welcomeService = WelcomeBackService();

  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final welcomeMessage =
    _welcomeService.getWelcomeBackMessage(widget.daysSinceLastVisit);
    final gardenStatus =
    _welcomeService.getGardenStatusMessage(widget.daysSinceLastVisit);
    final affirmation = _welcomeService.getReturnAffirmation();
    final restBonus =
    _welcomeService.calculateRestBonus(widget.daysSinceLastVisit);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CuteTheme.primaryGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedGarden(),
                  const SizedBox(height: 36),
                  Text(
                    welcomeMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: CuteTheme.deepGreen,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _buildStatusCard(gardenStatus),
                  const SizedBox(height: 24),
                  if (restBonus['water']! > 0 || restBonus['sunlight']! > 0)
                    _buildRestBonusCard(restBonus),
                  const SizedBox(height: 20),
                  _buildAffirmation(affirmation),
                  const SizedBox(height: 40),
                  _buildEnterButton(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFlowerDecoration(10),
                      const SizedBox(width: 10),
                      Text(
                        'Take your thyme. No rush.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: CuteTheme.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildFlowerDecoration(10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowerDecoration(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: CuteTheme.petalPink,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: CuteTheme.petalPink.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedGarden() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CuteTheme.petalPink.withValues(alpha: 0.3),
                      CuteTheme.primaryGreen.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: CuteTheme.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/thyme_icon_1024x1024.png',
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('🌿', style: TextStyle(fontSize: 48));
                      },
                    ),
                    if (widget.daysSinceLastVisit > 7)
                      Text(
                        'waking up...',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: CuteTheme.textGreen,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                  ],
                ),
              ),
              ..._buildFloatingDecorations(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildFloatingDecorations() {
    return [
      Positioned(
        top: 15,
        right: 20,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: CuteTheme.petalPink,
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
        ),
      ),
      Positioned(
        bottom: 25,
        left: 15,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: CuteTheme.lavender.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        top: 50,
        left: 10,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  Widget _buildStatusCard(String gardenStatus) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CuteTheme.borderLight.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              gardenStatus,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: CuteTheme.textGreen,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestBonusCard(Map<String, int> bonus) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(CuteTheme.radiusLarge),
        border: Border.all(
          color: CuteTheme.sunnyYellow.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.sunnyYellow.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎁', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Rest Bonus!',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CuteTheme.deepGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Your garden stored up resources while resting',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: CuteTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (bonus['water']! > 0)
                _buildBonusItem('💧', '+${bonus['water']}', 'Water', CuteTheme.waterBlue),
              if (bonus['water']! > 0 && bonus['sunlight']! > 0)
                Container(
                  width: 1,
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  color: CuteTheme.borderLight,
                ),
              if (bonus['sunlight']! > 0)
                _buildBonusItem('☀️', '+${bonus['sunlight']}', 'Sunlight', CuteTheme.warmOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusItem(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: CuteTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildAffirmation(String affirmation) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: CuteTheme.petalPink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💝', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              affirmation,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: CuteTheme.flowerCenter,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: CuteTheme.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Your Garden',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            const Text('🌸', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}

/// Show welcome back dialog as a modal
void showWelcomeBackDialog(
    BuildContext context, int daysSinceLastVisit, VoidCallback onContinue) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: CuteTheme.deepGreen.withValues(alpha: 0.3),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
          child: WelcomeBackScreen(
            daysSinceLastVisit: daysSinceLastVisit,
            onContinue: () {
              Navigator.pop(context);
              onContinue();
            },
          ),
        ),
      ),
    ),
  );
}