// widgets/cute_widgets.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/theme.dart';
import 'cute_garden_icons.dart';


class CuteCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool hasBorder;
  final bool hasShadow;
  final Color? borderColor;
  final Color? shadowColor;

  const CuteCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.hasBorder = true,
    this.hasShadow = true,
    this.borderColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? CuteTheme.cardBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? CuteTheme.radiusLarge),
        boxShadow: hasShadow
            ? [
          BoxShadow(
            color: (shadowColor ?? CuteTheme.primaryGreen).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
            : null,
        border: hasBorder
            ? Border.all(
          color: (borderColor ?? CuteTheme.borderLight).withValues(alpha: 0.5),
          width: 1,
        )
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: card,
      );
    }

    return card;
  }
}

class CuteGradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;

  const CuteGradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CuteCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      ),
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      hasBorder: false,
      child: child,
    );
  }
}

//animation
class CuteLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;

  const CuteLoadingWidget({
    super.key,
    this.message,
    this.size = 48,
    this.color,
  });

  @override
  State<CuteLoadingWidget> createState() => _CuteLoadingWidgetState();
}

class _CuteLoadingWidgetState extends State<CuteLoadingWidget>
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

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (widget.color ?? CuteTheme.primaryGreen).withValues(alpha: 0.2),
                        CuteTheme.petalPink.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CuteGardenIcon(
                      size: widget.size * 0.6,
                      isActive: true,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.message!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: CuteTheme.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型行内加载指示器
class CuteLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const CuteLoadingIndicator({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? CuteTheme.primaryGreen,
        ),
      ),
    );
  }
}

// 空狀態提示

class CuteEmptyState extends StatelessWidget {
  final Widget? icon;
  final String? emoji;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final List<Color>? gradientColors;

  const CuteEmptyState({
    super.key,
    this.icon,
    this.emoji,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors ??
                      [
                        CuteTheme.lavender.withValues(alpha: 0.3),
                        CuteTheme.petalPink.withValues(alpha: 0.2),
                      ],
                ),
                shape: BoxShape.circle,
              ),
              child: icon ??
                  (emoji != null
                      ? Text(emoji!, style: const TextStyle(fontSize: 40))
                      : const CuteGardenIcon(size: 48, isActive: true)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CuteTheme.deepGreen,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: CuteTheme.textMuted,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 20),
              CuteButton(
                text: actionText!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 資源顯示組件

class CuteResourceDisplay extends StatelessWidget {
  final int waterDrops;
  final int sunlightPoints;
  final bool compact;
  final bool showLabels;

  const CuteResourceDisplay({
    super.key,
    required this.waterDrops,
    required this.sunlightPoints,
    this.compact = false,
    this.showLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactItem(const CuteWaterDrop(size: 16), waterDrops, CuteTheme.waterBlue),
          const SizedBox(width: 12),
          _buildCompactItem(const CuteSunlight(size: 16), sunlightPoints, CuteTheme.warmOrange),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: CuteTheme.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CuteTheme.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildResourceItem(const CuteWaterDrop(size: 18), waterDrops, CuteTheme.waterBlue, showLabels ? 'Water' : null),
          Container(
            width: 1,
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            color: CuteTheme.borderLight,
          ),
          _buildResourceItem(const CuteSunlight(size: 18), sunlightPoints, CuteTheme.warmOrange, showLabels ? 'Sun' : null),
        ],
      ),
    );
  }

  Widget _buildCompactItem(Widget icon, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 4),
        Text(
          '$value',
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildResourceItem(Widget icon, int value, Color color, String? label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 4),
            Text('$value', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        if (label != null) ...[
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: CuteTheme.textMuted)),
        ],
      ],
    );
  }
}

class CuteRewardDisplay extends StatelessWidget {
  final int waterReward;
  final int sunlightReward;
  final double iconSize;
  final double fontSize;

  const CuteRewardDisplay({
    super.key,
    required this.waterReward,
    required this.sunlightReward,
    this.iconSize = 16,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('+$waterReward', style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.bold, color: CuteTheme.waterBlue)),
        const SizedBox(width: 2),
        CuteWaterDrop(size: iconSize),
        const SizedBox(width: 8),
        Text('+$sunlightReward', style: GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.bold, color: CuteTheme.warmOrange)),
        const SizedBox(width: 2),
        CuteSunlight(size: iconSize),
      ],
    );
  }
}

// 獎勵彈窗


class CuteRewardPopup {
  static void show(
      BuildContext context, {
        required int waterDrops,
        required int sunlightPoints,
        String? title,
        String? message,
        String? emoji,
        VoidCallback? onDismiss,
        Duration autoCloseDuration = const Duration(seconds: 3),
      }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
              child: _RewardPopupContent(
                waterDrops: waterDrops,
                sunlightPoints: sunlightPoints,
                title: title,
                message: message,
                emoji: emoji,
                autoCloseDuration: autoCloseDuration,
                onDismiss: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RewardPopupContent extends StatefulWidget {
  final int waterDrops;
  final int sunlightPoints;
  final String? title;
  final String? message;
  final String? emoji;
  final Duration autoCloseDuration;
  final VoidCallback onDismiss;

  const _RewardPopupContent({
    required this.waterDrops,
    required this.sunlightPoints,
    this.title,
    this.message,
    this.emoji,
    required this.autoCloseDuration,
    required this.onDismiss,
  });

  @override
  State<_RewardPopupContent> createState() => _RewardPopupContentState();
}

class _RewardPopupContentState extends State<_RewardPopupContent> {
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    // 關閉定時器
    Future.delayed(widget.autoCloseDuration, _safeDismiss);
  }

  // 確保只調用一次
  void _safeDismiss() {
    if (!mounted || _dismissed) return;
    _dismissed = true;
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _safeDismiss, // 點擊可關閉
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CuteTheme.petalPink.withValues(alpha: 0.95),
              Colors.white,
              CuteTheme.lavender.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: CuteTheme.flowerCenter.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          CuteTheme.primaryGreen.withValues(alpha: 0.3),
                          CuteTheme.petalPink.withValues(alpha: 0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: widget.emoji != null
                          ? Text(widget.emoji!, style: const TextStyle(fontSize: 40))
                          : const CuteSparkle(size: 48),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              widget.title ?? 'Wonderful!',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: CuteTheme.deepGreen),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: CuteTheme.textMuted, height: 1.5),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: CuteTheme.mintGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CuteTheme.mintGreen.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBadge(const CuteWaterDrop(size: 28), '+${widget.waterDrops}', 'Water'),
                  const SizedBox(width: 32),
                  _buildBadge(const CuteSunlight(size: 28), '+${widget.sunlightPoints}', 'Sunlight'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your garden thanks you~',
              style: GoogleFonts.poppins(fontSize: 12, color: CuteTheme.textMuted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(Widget icon, String amount, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: 6),
            Text(amount, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: CuteTheme.deepGreen)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: CuteTheme.textMuted)),
      ],
    );
  }
}

// 按鈕組件

class CuteButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final String? emoji;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final bool isOutlined;
  final bool isDanger;
  final Color? backgroundColor;
  final double? width;

  const CuteButton({
    super.key,
    required this.text,
    this.icon,
    this.emoji,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.isOutlined = false,
    this.isDanger = false,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ??
        (isDanger ? CuteTheme.errorRed : isPrimary ? CuteTheme.primaryGreen : CuteTheme.flowerCenter);

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CuteTheme.radiusMedium)),
            side: BorderSide(color: bgColor.withValues(alpha: 0.5), width: 1.5),
          ),
          child: _buildChild(bgColor),
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CuteTheme.radiusMedium)),
          elevation: 0,
        ),
        child: _buildChild(Colors.white),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(textColor.withValues(alpha: 0.8))),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[icon!, const SizedBox(width: 8)],
        Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: isOutlined ? textColor : null)),
        if (emoji != null) ...[const SizedBox(width: 8), Text(emoji!, style: const TextStyle(fontSize: 16))],
      ],
    );
  }
}


// 輸入框
class CuteInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CuteInputField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: CuteTheme.textGreen)),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: CuteTheme.cream,
            borderRadius: BorderRadius.circular(CuteTheme.radiusMedium),
            border: Border.all(color: CuteTheme.borderLight),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            maxLines: maxLines,
            minLines: minLines,
            enabled: enabled,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: GoogleFonts.poppins(fontSize: 15, color: CuteTheme.textDark),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: CuteTheme.textMuted.withValues(alpha: 0.6)),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

//標簽組件
class CuteChip extends StatelessWidget {
  final String text;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final bool selected;
  final VoidCallback? onTap;

  const CuteChip({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.textColor,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? CuteTheme.primaryGreen;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [chipColor.withValues(alpha: 0.2), chipColor.withValues(alpha: 0.1)])
              : null,
          color: selected ? null : chipColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: chipColor.withValues(alpha: selected ? 0.5 : 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: textColor ?? chipColor),
            ),
          ],
        ),
      ),
    );
  }
}

//提示條
class CuteSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        Widget? icon,
        String? emoji,
        Color? backgroundColor,
        Duration duration = const Duration(seconds: 2),
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 10)]
            else if (emoji != null) ...[Text(emoji, style: const TextStyle(fontSize: 18)), const SizedBox(width: 10)],
            Expanded(child: Text(message, style: GoogleFonts.poppins())),
          ],
        ),
        backgroundColor: backgroundColor ?? CuteTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CuteTheme.radiusSmall)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, icon: const CuteSparkle(size: 18), backgroundColor: CuteTheme.leafGreen);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, emoji: '😢', backgroundColor: CuteTheme.errorRed);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, emoji: '⚠️', backgroundColor: CuteTheme.warmOrange);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, emoji: '💡', backgroundColor: CuteTheme.skyBlue);
  }
}

//分割線
class CuteDivider extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  const CuteDivider({super.key, this.height, this.margin, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      height: height ?? 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            (color ?? CuteTheme.borderLight).withValues(alpha: 0.5),
            (color ?? CuteTheme.borderLight).withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.2, 0.8, 1.0],
        ),
      ),
    );
  }
}

//進度條

class CuteProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final Gradient? progressGradient;
  final double borderRadius;

  const CuteProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.progressGradient,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? CuteTheme.borderLight,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressGradient == null ? (progressColor ?? CuteTheme.primaryGreen) : null,
            gradient: progressGradient,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}


// 頭像組件
class CuteAvatar extends StatelessWidget {
  final String? name;
  final String? emoji;
  final Widget? icon;
  final double size;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  const CuteAvatar({
    super.key,
    this.name,
    this.emoji,
    this.icon,
    this.size = 48,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradientColors == null ? (backgroundColor ?? CuteTheme.primaryGreen.withValues(alpha: 0.2)) : null,
        gradient: gradientColors != null ? LinearGradient(colors: gradientColors!) : null,
        shape: BoxShape.circle,
        border: Border.all(color: CuteTheme.primaryGreen.withValues(alpha: 0.3), width: 2),
      ),
      child: Center(
        child: icon ??
            (emoji != null
                ? Text(emoji!, style: TextStyle(fontSize: size * 0.5))
                : Text(
              name?.isNotEmpty == true ? name![0].toUpperCase() : '🌱',
              style: GoogleFonts.poppins(fontSize: size * 0.4, fontWeight: FontWeight.w600, color: CuteTheme.deepGreen),
            )),
      ),
    );
  }
}


// 區塊標題
class CuteSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final String? emoji;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;

  const CuteSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.emoji,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (icon != null || emoji != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CuteTheme.primaryGreen.withValues(alpha: 0.15),
                    CuteTheme.petalPink.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: icon ?? Text(emoji!, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: CuteTheme.deepGreen),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(fontSize: 12, color: CuteTheme.textMuted),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              child: trailing,
            ),
        ],
      ),
    );
  }
}