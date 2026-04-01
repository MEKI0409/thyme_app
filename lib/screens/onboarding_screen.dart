// screens/onboarding_screen.dart
// Thyme App Onboarding Page - Cute Style Version 🌸
// Calm Gamification: Gentle onboarding - no pressure, just introduction

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'auth_screen.dart'; // ✅ FIXED: 导入 AuthScreen 以使用 startInRegisterMode 参数

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Welcome to Thyme',
      description:
      'A calm space to nurture your wellbeing.\nNo goals. No pressure. Just gentle growth.',
      emoji: '🌸',
      gradient: const LinearGradient(
        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      accentColor: CuteTheme.primaryGreen,
    ),
    _OnboardingPage(
      title: 'Gentle Habits',
      description:
      'Create small practices that matter to you.\nThere\'s no right pace - only your pace.',
      emoji: '🌱',
      gradient: const LinearGradient(
        colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      accentColor: CuteTheme.flowerCenter,
    ),
    _OnboardingPage(
      title: 'Express Freely',
      description:
      'A journal that listens without judgment.\nAll feelings are welcome here.',
      emoji: '💭',
      gradient: const LinearGradient(
        colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      accentColor: CuteTheme.skyBlue,
    ),
    _OnboardingPage(
      title: 'Watch It Bloom',
      description:
      'Your garden reflects your journey.\nIt never withers, only rests.',
      emoji: '🌷',
      gradient: const LinearGradient(
        colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      accentColor: CuteTheme.warmOrange,
    ),
    _OnboardingPage(
      title: 'A Gentle Friend',
      description:
      'An AI companion who\'s here when you need.\nNo advice unless you ask. Just presence.',
      emoji: '💝',
      gradient: const LinearGradient(
        colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      accentColor: CuteTheme.coralPink,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      // ✅ FIXED: 新用户完成 onboarding 后，直接进入注册模式（而非登录模式）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthScreen(startInRegisterMode: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: _pages[_currentPage].gradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              _buildSkipButton(),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page indicators
              _buildIndicators(),

              // Navigation buttons
              _buildNavigationButtons(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          onPressed: _completeOnboarding,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: Colors.white.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Skip',
            style: GoogleFonts.poppins(
              color: CuteTheme.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating Emoji icon
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring decoration
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    // Middle ring
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: page.accentColor.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    // Emoji
                    Text(
                      page.emoji,
                      style: const TextStyle(fontSize: 70),
                    ),
                    // Small decorative flowers
                    ..._buildDecorativeFlowers(page.accentColor),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 50),

          // Title
          Text(
            page.title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: CuteTheme.deepGreen,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: CuteTheme.textGreen,
              fontWeight: FontWeight.w300,
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDecorativeFlowers(Color accentColor) {
    return [
      const Positioned(
        top: 10,
        right: 25,
        child: _SmallFlower(color: CuteTheme.petalPink, size: 18),
      ),
      Positioned(
        bottom: 15,
        left: 20,
        child: _SmallFlower(color: accentColor.withValues(alpha: 0.6), size: 14),
      ),
      Positioned(
        top: 50,
        left: 10,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: CuteTheme.lavender.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: 40,
        right: 15,
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

  Widget _buildIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pages.length, (index) {
          final isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? _pages[_currentPage].accentColor
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(5),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: _pages[_currentPage].accentColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          AnimatedOpacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: _currentPage > 0
                  ? () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              }
                  : null,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.arrow_back_rounded,
                    color: CuteTheme.textMuted,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Back',
                    style: GoogleFonts.poppins(
                      color: CuteTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next / Begin button
          ElevatedButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              } else {
                _completeOnboarding();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _pages[_currentPage].accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
              shadowColor: _pages[_currentPage].accentColor.withValues(alpha: 0.4),
            ),
            child: Row(
              children: [
                Text(
                  _currentPage < _pages.length - 1 ? 'Next' : 'Begin',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _currentPage < _pages.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.favorite_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final String emoji;
  final Gradient gradient;
  final Color accentColor;

  _OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
    required this.gradient,
    required this.accentColor,
  });
}

class _SmallFlower extends StatelessWidget {
  final Color color;
  final double size;

  const _SmallFlower({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: const BoxDecoration(
            color: CuteTheme.flowerCenter,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Check if onboarding should be shown
Future<bool> shouldShowOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('onboarding_complete') ?? false);
}