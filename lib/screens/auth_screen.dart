// screens/auth_screen.dart
// Thyme App Login/Register Page - Cute Style Version

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../controllers/auth_controller.dart';
import '../utils/theme.dart';

class AuthScreen extends StatefulWidget {
  /// ✅ FIXED: 支持通过参数控制默认显示登录还是注册
  /// startInRegisterMode: true = 显示注册页（新用户从 onboarding 来）
  ///                      false = 显示登录页（默认，老用户）
  final bool startInRegisterMode;

  const AuthScreen({Key? key, this.startInRegisterMode = false}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late bool _isLoginMode = !widget.startInRegisterMode; // ✅ FIXED: 根据参数决定初始模式
  bool _obscurePassword = true;

  late AnimationController _floatController;
  late AnimationController _formController;
  late AnimationController _decorController;
  late Animation<double> _floatAnimation;
  late Animation<double> _formAnimation;

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

    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _formAnimation = CurvedAnimation(
      parent: _formController,
      curve: Curves.easeOutCubic,
    );

    _decorController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _floatController.dispose();
    _formController.dispose();
    _decorController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
    _formController.reset();
    _formController.forward();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = Provider.of<AuthController>(context, listen: false);

    bool success;
    if (_isLoginMode) {
      success = await authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      success = await authController.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted && authController.errorMessage != null) {
      _showErrorSnackBar(authController.errorMessage!);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('😅', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: CuteTheme.coralPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: CuteTheme.primaryGradient,
        ),
        child: Stack(
          children: [
            _buildDecorations(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: AnimatedBuilder(
                    animation: _formAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _formAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - _formAnimation.value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 32),
                        _buildWelcomeText(),
                        const SizedBox(height: 32),
                        _buildFormCard(),
                        const SizedBox(height: 20),
                        _buildToggleButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorations() {
    return AnimatedBuilder(
      animation: _decorController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _CuteBackgroundPainter(
            progress: _decorController.value,
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              boxShadow: [
                BoxShadow(
                  color: CuteTheme.primaryGreen.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: CuteTheme.petalPink.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Image.asset(
                'assets/thyme_icon_1024x1024.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      '🌿',
                      style: TextStyle(fontSize: 48),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          _isLoginMode ? 'Welcome Back!' : 'Join the Garden',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: CuteTheme.deepGreen,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlowerDecoration(12),
            const SizedBox(width: 10),
            Text(
              _isLoginMode
                  ? 'Your garden has been waiting'
                  : 'Create your peaceful space',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: CuteTheme.textGreen,
              ),
            ),
            const SizedBox(width: 10),
            _buildFlowerDecoration(12),
          ],
        ),
      ],
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

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(CuteTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: CuteTheme.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: CuteTheme.borderLight.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isLoginMode
                  ? const SizedBox.shrink()
                  : Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Your Name',
                    hint: 'What should we call you?',
                    icon: Icons.face_outlined,
                    validator: (value) {
                      if (!_isLoginMode && (value == null || value.isEmpty)) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'your@email.com',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: CuteTheme.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            Consumer<AuthController>(
              builder: (context, authController, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authController.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CuteTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: authController.isLoading
                        ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLoginMode ? 'Enter Garden' : 'Plant My Seed',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _isLoginMode ? '🌸' : '🌱',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.poppins(
        color: CuteTheme.textDark,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(
          color: CuteTheme.textMuted,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: GoogleFonts.poppins(
          color: CuteTheme.textMuted.withValues(alpha: 0.5),
        ),
        prefixIcon: Icon(icon, color: CuteTheme.primaryGreen, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: CuteTheme.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CuteTheme.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: CuteTheme.primaryGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: CuteTheme.errorRed.withValues(alpha: 0.7), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleMode,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isLoginMode ? 'New here? ' : 'Already growing? ',
            style: GoogleFonts.poppins(
              color: CuteTheme.textMuted,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            _isLoginMode ? 'Join Us 🌱' : 'Sign In 🌸',
            style: GoogleFonts.poppins(
              color: CuteTheme.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CuteBackgroundPainter extends CustomPainter {
  final double progress;

  _CuteBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final decorations = [
      _Decoration(0.08, 0.12, 20, CuteTheme.petalPink, true),
      _Decoration(0.92, 0.08, 16, CuteTheme.petalLight, true),
      _Decoration(0.05, 0.85, 18, CuteTheme.lavender, true),
      _Decoration(0.88, 0.78, 22, CuteTheme.petalPink, true),
      _Decoration(0.75, 0.15, 12, CuteTheme.primaryGreen.withValues(alpha: 0.3), false),
      _Decoration(0.15, 0.65, 14, CuteTheme.primaryGreen.withValues(alpha: 0.2), false),
      _Decoration(0.85, 0.55, 10, CuteTheme.lavender.withValues(alpha: 0.4), false),
      _Decoration(0.25, 0.25, 8, CuteTheme.petalMid.withValues(alpha: 0.3), false),
    ];

    for (final deco in decorations) {
      final offsetY = math.sin(progress * 2 * math.pi + deco.x * 10) * 8;
      final x = size.width * deco.x;
      final y = size.height * deco.y + offsetY;

      paint.color = deco.color.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(x, y), deco.size, paint);

      if (deco.isFlower) {
        paint.color = CuteTheme.flowerCenter.withValues(alpha: 0.7);
        canvas.drawCircle(Offset(x, y), deco.size * 0.4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CuteBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Decoration {
  final double x;
  final double y;
  final double size;
  final Color color;
  final bool isFlower;

  _Decoration(this.x, this.y, this.size, this.color, this.isFlower);
}