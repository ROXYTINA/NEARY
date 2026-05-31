import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette — rose/gold/cream
  static const Color roseLight     = Color(0xFFF9E4EC);
  static const Color roseMid       = Color(0xFFF2BDD0);
  static const Color roseDark      = Color(0xFFD4849F);
  static const Color rosePrimary   = Color(0xFFBF5070);

  static const Color goldLight     = Color(0xFFFDF6E3);
  static const Color goldMid       = Color(0xFFE8C97E);
  static const Color goldAccent    = Color(0xFFC8974A);
  static const Color goldDeep      = Color(0xFF9A6C28);

  static const Color cream         = Color(0xFFFDF8F2);
  static const Color creamDark     = Color(0xFFF5EDE0);

  static const Color blushWhite    = Color(0xFFFEF9FB);

  // Neutrals
  static const Color charcoal      = Color(0xFF2D2025);
  static const Color warmGrey      = Color(0xFF7A6872);
  static const Color softGrey      = Color(0xFFBFB0B8);
  static const Color divider       = Color(0xFFEDE0E8);

  // Semantic
  static const Color success       = Color(0xFF6BBF8C);
  static const Color warning       = Color(0xFFE8A96B);
  static const Color error         = Color(0xFFD95B6A);

  // Dark theme equivalents
  static const Color darkBg        = Color(0xFF1A1218);
  static const Color darkSurface   = Color(0xFF261E22);
  static const Color darkCard      = Color(0xFF31252C);
  static const Color darkRose      = Color(0xFF8C3A53);
  static const Color darkGold      = Color(0xFFC8974A);
  static const Color darkText      = Color(0xFFF5E6EE);
  static const Color darkSubtext   = Color(0xFF9E8A94);

  // Star rating
  static const Color starFilled    = Color(0xFFE8C97E);
  static const Color starEmpty     = Color(0xFFEADDE5);

  // Category chips
  static const List<Color> categoryColors = [
    Color(0xFFF9E4EC), // Hair
    Color(0xFFEEE4F9), // Nails
    Color(0xFFE4EEF9), // Makeup
    Color(0xFFE4F9EE), // Spa
    Color(0xFFF9F4E4), // Bridal
  ];
}