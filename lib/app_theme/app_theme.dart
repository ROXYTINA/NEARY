import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: AppColors.rosePrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.roseLight,
        onPrimaryContainer: AppColors.charcoal,
        secondary: AppColors.goldAccent,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.goldLight,
        onSecondaryContainer: AppColors.charcoal,
        surface: AppColors.blushWhite,
        onSurface: AppColors.charcoal,
        surfaceContainerHighest: AppColors.creamDark,
        error: AppColors.error,
        outline: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Jost',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTextStyles.displaySm,
        centerTitle: true,
      ),
      // Card theme intentionally omitted to avoid SDK mismatches; use Card widgets directly where needed.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rosePrimary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.rosePrimary,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.rosePrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.rosePrimary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.rosePrimary,
          textStyle: AppTextStyles.labelLg.copyWith(color: AppColors.rosePrimary),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.roseLight,
        selectedColor: AppColors.rosePrimary,
        labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.charcoal),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blushWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.rosePrimary, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.softGrey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blushWhite,
        selectedItemColor: AppColors.rosePrimary,
        unselectedItemColor: AppColors.softGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.navLabel,
        unselectedLabelStyle: AppTextStyles.navLabel,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: AppTextStyles.bodyMd.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.rosePrimary,
        linearTrackColor: AppColors.roseLight,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkRose,
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkCard,
        onPrimaryContainer: AppColors.darkText,
        secondary: AppColors.darkGold,
        onSecondary: AppColors.darkBg,
        secondaryContainer: AppColors.darkSurface,
        onSecondaryContainer: AppColors.darkText,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkText,
        surfaceContainerHighest: AppColors.darkCard,
        error: AppColors.error,
        outline: const Color(0xFF4A3840),
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      fontFamily: 'Jost',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        titleTextStyle: AppTextStyles.displaySm.copyWith(color: AppColors.darkText),
        centerTitle: true,
      ),
      // Card theme intentionally omitted for dark theme as well.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRose,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkRose,
        unselectedItemColor: AppColors.darkSubtext,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A3840)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4A3840)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkRose, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.darkSubtext),
      ),
    );
  }
}