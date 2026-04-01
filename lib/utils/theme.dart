// utils/theme.dart
// Cute Style Theme - Supporting both AppTheme and CuteTheme class names
// Color inspiration: Thyme wreath - Soft green + Pink-purple petal colors 🌸

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🌿 Primary Colors - Soft Green Series
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color primaryColor = Color(0xFF7AC996);
  static const Color primaryGreen = Color(0xFF7AC996);     // CuteTheme alias
  static const Color primaryLight = Color(0xFFB0DDB8);
  static const Color primaryDark = Color(0xFF5BA97A);
  static const Color softGreen = Color(0xFFB0DDB8);
  static const Color leafGreen = Color(0xFF6BBF8A);
  static const Color mintGreen = Color(0xFF9DD4B0);
  static const Color deepGreen = Color(0xFF3D6B4F);
  static const Color textGreen = Color(0xFF5A8A6A);

  static const Color secondaryColor = Color(0xFFE8D0F0);
  static const Color accentColor = Color(0xFFFFE082);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌸 Petal Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color petalPink = Color(0xFFE8D0F0);
  static const Color petalLight = Color(0xFFF0D8F4);
  static const Color petalMid = Color(0xFFE0C8EC);
  static const Color flowerCenter = Color(0xFFC490D0);
  static const Color lavender = Color(0xFFD4B8E0);
  static const Color coralPink = Color(0xFFFFAB91);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🏠 Background Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color backgroundColor = Color(0xFFFAF8F5);
  static const Color warmWhite = Color(0xFFFAF8F5);
  static const Color surfaceColor = Color(0xFFFFFEFC);
  static const Color cardColor = Color(0xFFFFFEFC);
  static const Color cardBg = Color(0xFFFFFEFC);
  static const Color cream = Color(0xFFFFFBF5);
  static const Color borderLight = Color(0xFFEDE5DA);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 Text Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF3D6B4F);
  static const Color textDark = Color(0xFF3D6B4F);
  static const Color textSecondary = Color(0xFF5A8A6A);
  static const Color textMuted = Color(0xFF8A9A8E);
  static const Color textHint = Color(0xFF8A9A8E);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎯 Status Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color successColor = Color(0xFF81C784);
  static const Color warningColor = Color(0xFFFFCC80);
  static const Color warmOrange = Color(0xFFFFCC80);
  static const Color errorColor = Color(0xFFE57373);
  static const Color errorRed = Color(0xFFE57373);         // alias
  static const Color infoColor = Color(0xFF90CAF9);
  static const Color skyBlue = Color(0xFF90CAF9);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌸 Garden Resource Colors
  // ═══════════════════════════════════════════════════════════════════════════
  static const Color waterColor = Color(0xFF81D4FA);
  static const Color waterBlue = Color(0xFF81D4FA);
  static const Color sunlightColor = Color(0xFFFFCC80);
  static const Color sunnyYellow = Color(0xFFFFE082);

  // ═══════════════════════════════════════════════════════════════════════════
  // 📐 Spacing
  // ═══════════════════════════════════════════════════════════════════════════
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔵 Border Radius - More rounded and cute
  // ═══════════════════════════════════════════════════════════════════════════
  static const double radiusS = 12.0;
  static const double radiusSmall = 12.0;
  static const double radiusM = 16.0;
  static const double radiusMedium = 18.0;
  static const double radiusL = 20.0;
  static const double radiusLarge = 24.0;
  static const double radiusXL = 28.0;
  static const double radiusXLarge = 32.0;
  static const double radiusRound = 100.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Gradients
  // ═══════════════════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFC8E6D0),
      Color(0xFFB0DDB8),
      Color(0xFF9DD4B0),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFEFC),
      Color(0xFFF5FAF7),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 💫 Shadows
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.12),
      blurRadius: 25,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔘 Button Styles
  // ═══════════════════════════════════════════════════════════════════════════
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryGreen,
    side: BorderSide(color: primaryGreen.withValues(alpha: 0.5), width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  static ButtonStyle pinkButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: flowerCenter,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMedium),
    ),
    textStyle: GoogleFonts.poppins(
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 📱 ThemeData
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get themeData => lightTheme;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.green,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w300,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w300,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.5,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusL)),
      color: cardColor,
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: borderLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.poppins(
        color: textHint,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 14,
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textHint,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: cream,
      selectedColor: primaryColor.withValues(alpha: 0.2),
      labelStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusRound),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: borderLight,
      thickness: 1,
      space: spacingM,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusM),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: textSecondary,
      ),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radiusXL),
        ),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 Helper Methods
  // ═══════════════════════════════════════════════════════════════════════════

  static LinearGradient getMoodGradient(String? mood) {
    switch (mood?.toLowerCase()) {
      case 'happy':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
        );
      case 'calm':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        );
      case 'sad':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        );
      case 'anxious':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
        );
      case 'stressed':
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        );
    }
  }

  static BoxDecoration cardDecoration({
    Color? color,
    double? borderRadius,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: color ?? cardColor,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
      boxShadow: shadow ?? cardShadow,
    );
  }

  static BoxDecoration get cuteCardDecoration => BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: softShadow,
    border: Border.all(color: borderLight.withValues(alpha: 0.5), width: 1),
  );

  static BoxDecoration gradientCardDecoration({
    required List<Color> colors,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      borderRadius: BorderRadius.circular(borderRadius ?? radiusL),
      boxShadow: subtleShadow,
    );
  }

  static InputDecoration inputDecoration({
    required String hint,
    String? label,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Widget? suffixWidget,
    VoidCallback? onSuffixTap,
  }) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: primaryGreen, size: 22)
          : null,
      suffixIcon: suffixWidget ?? (suffixIcon != null
          ? IconButton(
        icon: Icon(suffixIcon, color: textHint, size: 20),
        onPressed: onSuffixTap,
      )
          : null),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ✅ CuteTheme Alias - Makes all code using CuteTheme work
// ═══════════════════════════════════════════════════════════════════════════
typedef CuteTheme = AppTheme;

// ═══════════════════════════════════════════════════════════════════════════
// 🌸 Cute Decoration Widgets
// ═══════════════════════════════════════════════════════════════════════════

/// Small flower decoration
class CuteFlowerDecoration extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteFlowerDecoration({
    Key? key,
    this.size = 16,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final flowerColor = color ?? AppTheme.petalPink;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: flowerColor.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: const BoxDecoration(
            color: AppTheme.flowerCenter,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// Decoration dot
class CuteDotDecoration extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteDotDecoration({
    Key? key,
    this.size = 6,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: (color ?? AppTheme.lavender).withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ✅ CuteCard 和 CuteButton 已移至 cute_widgets.dart，避免重复定义
// 请使用: import '../widgets/cute_widgets.dart';