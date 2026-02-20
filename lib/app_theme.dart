import 'dart:ui';
import 'package:flutter/material.dart';

/// ─── Color Palette ───────────────────────────────────────────────
class AppColors {
  // Primary palette
  static const Color sage = Color(0xFF899481);
  static const Color beige = Color(0xFFCDBCAB);
  static const Color cream = Color(0xFFEFE9E1);

  // Darker shades
  static const Color sageDark = Color(0xFF6B7A62);
  static const Color sageDeep = Color(0xFF4E5E45);
  static const Color beigeDark = Color(0xFFB5A08A);
  static const Color warmBrown = Color(0xFF8B7355);

  // Lighter shades
  static const Color sageLight = Color(0xFFA8B3A0);
  static const Color beigeLight = Color(0xFFDDD1C4);
  static const Color creamLight = Color(0xFFF7F4F0);
  static const Color white = Color(0xFFFFFEFC);

  // Contrast / Accent
  static const Color accent = Color(0xFF6B8F71);       // Forest green accent
  static const Color accentWarm = Color(0xFFC4956A);    // Warm amber accent
  static const Color error = Color(0xFFB85C5C);         // Muted red
  static const Color success = Color(0xFF6B9B6B);       // Soft green
  static const Color warning = Color(0xFFD4A843);       // Gold
  static const Color info = Color(0xFF7A9BAE);          // Dusty blue

  // Text
  static const Color textPrimary = Color(0xFF3A3A3A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF999999);
  static const Color textOnDark = Color(0xFFF5F2EE);
}

/// ─── Neumorphic Decoration ───────────────────────────────────────
class NeuDecoration {
  static BoxDecoration raised({
    Color color = AppColors.cream,
    double radius = 16,
    double spread = 1,
    double blur = 8,
    double offset = 4,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          offset: Offset(-offset, -offset),
          blurRadius: blur,
          spreadRadius: spread,
        ),
        BoxShadow(
          color: const Color(0xFFBEB8AE).withOpacity(0.5),
          offset: Offset(offset, offset),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ],
    );
  }

  static BoxDecoration pressed({
    Color color = AppColors.cream,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFBEB8AE).withOpacity(0.35),
          offset: const Offset(2, 2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.6),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ],
    );
  }

  static BoxDecoration flat({
    Color color = AppColors.cream,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// ─── Glassmorphic Container ──────────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double blur;
  final Color? color;
  final double opacity;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.blur = 12,
    this.color,
    this.opacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// ─── Neumorphic Text Field ───────────────────────────────────────
class NeuTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const NeuTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NeuDecoration.pressed(color: AppColors.creamLight, radius: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textLight),
          prefixIcon: Icon(prefixIcon, color: AppColors.sage, size: 22),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.sage, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

/// ─── Neumorphic Button ───────────────────────────────────────────
class NeuButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double width;
  final double height;

  const NeuButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.color = AppColors.sage,
    this.textColor = AppColors.white,
    this.width = double.infinity,
    this.height = 52,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: _isPressed
            ? NeuDecoration.pressed(color: widget.color, radius: 14)
            : NeuDecoration.raised(color: widget.color, radius: 14, offset: 3, blur: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── App Theme ───────────────────────────────────────────────────
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.cream,
      primaryColor: AppColors.sage,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage,
        primary: AppColors.sage,
        secondary: AppColors.beige,
        surface: AppColors.cream,
        error: AppColors.error,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.sage,
          textStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamLight,
        selectedItemColor: AppColors.sage,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.sageDark,
        contentTextStyle: const TextStyle(color: AppColors.textOnDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.sage,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.beige.withOpacity(0.5),
        thickness: 1,
      ),
    );
  }
}
