import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // --- Display / Hero (Cormorant Serif) ---
  static const TextStyle heroDisplay = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.5,
    color: AppColors.charcoal,
  );

  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.15,
    color: AppColors.charcoal,
  );

  static const TextStyle displayMd = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.charcoal,
  );

  static const TextStyle displaySm = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.charcoal,
  );

  // --- Title aliases used across app ---
  static const TextStyle titleLg = displayMd;
  static const TextStyle titleMd = displaySm;

  static const TextStyle displayItalic = TextStyle(
    fontFamily: 'Cormorant',
    fontSize: 26,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.2,
    color: AppColors.rosePrimary,
  );

  // --- Body / UI (Jost) ---
  static const TextStyle bodyLg = TextStyle(
    fontFamily: 'Jost',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.charcoal,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Jost',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.charcoal,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: 'Jost',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.warmGrey,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: 'Jost',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: AppColors.charcoal,
  );

  static const TextStyle labelMd = TextStyle(
    fontFamily: 'Jost',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    color: AppColors.warmGrey,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Jost',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: AppColors.warmGrey,
  );

  static const TextStyle price = TextStyle(
    fontFamily: 'Jost',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.rosePrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle priceSm = TextStyle(
    fontFamily: 'Jost',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.rosePrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'Jost',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: Colors.white,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Jost',
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.3,
    color: AppColors.warmGrey,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Jost',
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}