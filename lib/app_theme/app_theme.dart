
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Jost',
    scaffoldBackgroundColor: AppColors.creamDark,
    colorScheme: const ColorScheme.light(
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

    textTheme: _textTheme(AppColors.charcoal, AppColors.warmGrey),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: AppTextStyles.displaySm,
      iconTheme: IconThemeData(color: AppColors.charcoal),

    ),

    cardTheme: CardThemeData(
      color: Colors.white, // pure white instead of blushWhite
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.rosePrimary,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.rosePrimary,
        textStyle: AppTextStyles.button,
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: AppColors.rosePrimary, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.rosePrimary,
        textStyle: AppTextStyles.labelLg,
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.roseLight,
      selectedColor: AppColors.rosePrimary,
      labelStyle: AppTextStyles.labelMd.copyWith(color: AppColors.charcoal),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
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
        borderSide:
        const BorderSide(color: AppColors.rosePrimary, width: 1.5),
      ),
      hintStyle:
      AppTextStyles.bodyMd.copyWith(color: AppColors.softGrey),
      labelStyle:
      AppTextStyles.bodyMd.copyWith(color: AppColors.warmGrey),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.warmGrey,
      textColor: AppColors.charcoal,
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
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.rosePrimary,
      unselectedLabelColor: AppColors.warmGrey,
      indicatorColor: AppColors.rosePrimary,
      dividerColor: AppColors.divider,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.charcoal,
      contentTextStyle:
      AppTextStyles.bodyMd.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.rosePrimary,
      linearTrackColor: AppColors.roseLight,
    ),
    iconTheme: const IconThemeData(color: AppColors.warmGrey),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.rosePrimary,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
      WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? AppColors.rosePrimary
          : AppColors.softGrey),
      trackColor:
      WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? AppColors.roseMid
          : AppColors.divider),
    ),
  );



  // ── Dark Theme ────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Jost',
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFB3C6),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF4A1A2A),
      onPrimaryContainer: AppColors.darkText,
      secondary: AppColors.darkGold,
      onSecondary: AppColors.darkBg,
      secondaryContainer: AppColors.darkSurface,
      onSecondaryContainer: AppColors.darkText,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkCard,
      error: AppColors.error,
      outline: Color(0xFF4A3840),
    ),
    textTheme: _textTheme(AppColors.darkText, AppColors.darkSubtext),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkText,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle:
      AppTextStyles.displaySm.copyWith(color: AppColors.darkText),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF4A3840)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkRose,
        foregroundColor: Colors.white,
        textStyle: AppTextStyles.button,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkRose,
        textStyle: AppTextStyles.button,
        padding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: AppColors.darkRose, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkRose,
        textStyle: AppTextStyles.labelLg,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.darkRose,
      labelStyle:
      AppTextStyles.labelMd.copyWith(color: AppColors.darkText),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
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
        borderSide:
        const BorderSide(color: AppColors.darkRose, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMd
          .copyWith(color: AppColors.darkSubtext),
      labelStyle: AppTextStyles.bodyMd
          .copyWith(color: AppColors.darkSubtext),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.darkSubtext,
      textColor: AppColors.darkText,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkRose,
      unselectedItemColor: AppColors.darkSubtext,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.darkRose,
      unselectedLabelColor: AppColors.darkSubtext,
      indicatorColor: AppColors.darkRose,
      dividerColor: Color(0xFF4A3840),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF4A3840),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkCard,
      contentTextStyle:
      AppTextStyles.bodyMd.copyWith(color: AppColors.darkText),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.darkRose,
      linearTrackColor: AppColors.darkSurface,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkSubtext),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkRose,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor:
      WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? AppColors.darkRose
          : AppColors.darkSubtext),
      trackColor:
      WidgetStateProperty.resolveWith((states) =>
      states.contains(WidgetState.selected)
          ? AppColors.darkRose.withValues(alpha: 0.4)
          : AppColors.darkCard),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.darkSurface,
    ),
  );


  // ── Shared Text Theme ─────────────────────────────────────
  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge:  TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.bold),
    displaySmall:  TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w600),
    headlineLarge: TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.bold),
    headlineMedium:TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w600),
    titleLarge:    TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w600),
    titleMedium:   TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w500),
    titleSmall:    TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w500),
    bodyLarge:     TextStyle(color: primary,   fontFamily: 'Jost'),
    bodyMedium:    TextStyle(color: primary,   fontFamily: 'Jost'),
    bodySmall:     TextStyle(color: secondary, fontFamily: 'Jost'),
    labelLarge:    TextStyle(color: primary,   fontFamily: 'Jost', fontWeight: FontWeight.w600),
    labelMedium:   TextStyle(color: secondary, fontFamily: 'Jost'),
    labelSmall:    TextStyle(color: secondary, fontFamily: 'Jost', fontSize: 11),
  );
}