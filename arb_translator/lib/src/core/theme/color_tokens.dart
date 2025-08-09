import 'package:flutter/material.dart';

/// Central dark theme color tokens for consistent styling.
class AppColors {
  // Backgrounds
  static const Color bgRoot = Color(0xFF0F0F10);
  static const Color bgPanel = Color(0xFF161719);
  static const Color bgPanelAlt = Color(0xFF1F2022);
  static const Color bgTable = Color(0xFF1A1B1D);

  // Borders / dividers
  static const Color border = Color(0xFF2A2C2E);
  static const Color borderStrong = Color(0xFF3A3C3F);

  // Text
  static const Color textPrimary = Color(0xFFE5E6E8);
  static const Color textSecondary = Color(0xFFB0B2B5);
  static const Color textDisabled = Color(0xFF6A6C70);

  // Accents / states
  static const Color accent = Color(0xFF3399FF);
  static const Color accentHover = Color(0xFF52A9FF);
  static const Color accentActive = Color(0xFF0F7AD9);

  static const Color danger = Color(0xFFFF5570);
  static const Color warning = Color(0xFFF5B94C);
  static const Color success = Color(0xFF52C77A);

  // Table specifics
  static const Color rowHover = Color(0xFF25272A);
  static const Color rowSelected = Color(0xFF283646);
  static const Color cellDirtyMark = Color(0xFFED9F3B);
  static const Color cellErrorBg = Color(0x33FF5570);
  static const Color placeholderChip = Color(0xFF314458);
}
