import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

/// Text style tokens centralizing typography for consistency.
class AppTextStyles {
  // Base body / content
  static const TextStyle body13 = TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.2);
  static const TextStyle body13Secondary = TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.2);

  // Table specific
  static const TextStyle tableCell13 = body13;
  static const TextStyle tableHeader13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Captions / meta
  static const TextStyle caption11 = TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.15);
  static const TextStyle danger11 = TextStyle(fontSize: 11, color: AppColors.danger, height: 1.15);

  // Headings
  static const TextStyle heading14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
}
