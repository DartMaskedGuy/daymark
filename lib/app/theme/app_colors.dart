import 'package:flutter/material.dart';

/// Central color palette for Daymark. Screens reference these tokens
/// instead of hardcoding colors, so light/dark theming stays consistent.
class AppColors {
  AppColors._();

  static const lightBackground = Color(0xFFF8F8FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightPrimary = Color(0xFF5B5FEF);
  static const lightPrimaryDark = Color(0xFF4548C7);
  static const lightTextPrimary = Color(0xFF18181B);
  static const lightTextSecondary = Color(0xFF71717A);
  static const lightBorder = Color(0xFFE4E4E7);
  static const lightSuccess = Color(0xFF22A06B);

  static const darkBackground = Color(0xFF0F0F14);
  static const darkSurface = Color(0xFF18181F);
  static const darkPrimary = Color(0xFF777AFF);
  static const darkPrimaryDark = Color(0xFF9A9CFF);
  static const darkTextPrimary = Color(0xFFF5F5F7);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkBorder = Color(0xFF292932);
  static const darkSuccess = Color(0xFF34C98A);

  /// Curated palette users pick from for a bucket-list item's accent color.
  /// Keys are persisted in the database (BucketListItems.color).
  static const Map<String, Color> itemPalette = {
    'indigo': Color(0xFF5B5FEF),
    'violet': Color(0xFF8B5CF6),
    'blue': Color(0xFF3B82F6),
    'teal': Color(0xFF14B8A6),
    'green': Color(0xFF22A06B),
    'yellow': Color(0xFFEAB308),
    'orange': Color(0xFFF97316),
    'red': Color(0xFFEF4444),
    'pink': Color(0xFFEC4899),
    'neutral': Color(0xFF71717A),
  };

  static Color fromKey(String? key) =>
      itemPalette[key] ?? itemPalette['indigo']!;
}
