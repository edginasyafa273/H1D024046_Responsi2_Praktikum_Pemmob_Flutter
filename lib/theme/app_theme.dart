import 'package:flutter/material.dart';

/// Palet warna pastel & aksen yang terinspirasi dari gaya soft-blue modern.
class AppPalette {
  AppPalette._();

  static const Color primaryBlue = Color(0xFF4A88F7);
  static const Color deepBlue = Color(0xFF2D6AE0);
  static const Color skyLight = Color(0xFFEAF2FF);
  static const Color skyMid = Color(0xFFC5DCFF);
  static const Color skyAccent = Color(0xFF8CB9FF);

  static const Color scaffoldLight = Color(0xFFF4F7FC);
  static const Color scaffoldDark = Color(0xFF0E1525);
  static const Color cardDark = Color(0xFF172036);

  static const Color textDark = Color(0xFF131B2E);
  static const Color textMuted = Color(0xFF6B778D);

  // Warna pastel untuk badge & pill detail cuaca.
  static const Color blueSoft = Color(0xFFE4EEFF);
  static const Color blueIcon = Color(0xFF4A88F7);

  static const Color greenSoft = Color(0xFFD9F7E4);
  static const Color greenIcon = Color(0xFF2FA866);

  static const Color purpleSoft = Color(0xFFEEE6FF);
  static const Color purpleIcon = Color(0xFF7C5CFA);

  static const Color amberSoft = Color(0xFFFFF1DB);
  static const Color amberIcon = Color(0xFFEA8C1E);

  static const Color cyanSoft = Color(0xFFDCF5FA);
  static const Color cyanIcon = Color(0xFF1792B0);

  static const Color roseSoft = Color(0xFFFFE6EC);
  static const Color roseIcon = Color(0xFFE55376);
}

/// Theme (Material 3) dan Typography aplikasi, dipakai di seluruh screen
/// supaya tampilan konsisten. Mendukung mode terang dan gelap.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primaryBlue,
      brightness: brightness,
      primary: AppPalette.primaryBlue,
      surface: isDark ? AppPalette.cardDark : Colors.white,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor:
          isDark ? AppPalette.scaffoldDark : AppPalette.scaffoldLight,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : AppPalette.textDark,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppPalette.cardDark : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      textTheme: _textTheme(base.textTheme, isDark),
    );
  }

  /// Typography: ukuran dan ketebalan dibuat jelas dan mudah dibaca.
  static TextTheme _textTheme(TextTheme t, bool isDark) {
    final primaryColor = isDark ? Colors.white : AppPalette.textDark;
    final mutedColor =
        isDark ? const Color(0xFF9BA8C2) : AppPalette.textMuted;

    return t.copyWith(
      displayLarge: t.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: primaryColor,
      ),
      headlineMedium: t.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: primaryColor,
      ),
      titleLarge: t.titleLarge?.copyWith(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primaryColor,
      ),
      titleMedium: t.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: t.bodyLarge?.copyWith(
        fontSize: 15,
        height: 1.4,
        color: primaryColor,
      ),
      bodyMedium: t.bodyMedium?.copyWith(
        fontSize: 13.5,
        height: 1.4,
        color: mutedColor,
      ),
      labelMedium: t.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
    );
  }

  /// BoxDecoration standar untuk kartu putih bersih dengan bayangan lembut.
  static BoxDecoration cardDecoration(BuildContext context,
      {double radius = 24}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? AppPalette.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFEBF0FA),
      ),
      boxShadow: [
        if (!isDark)
          BoxShadow(
            color: AppPalette.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
      ],
    );
  }
}
