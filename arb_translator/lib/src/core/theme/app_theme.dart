import 'package:arb_translator/src/core/theme/color_tokens.dart';
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final base = ThemeData.dark();
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bgRoot,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.bgPanel,
      onPrimary: AppColors.textPrimary,
    ),
    textTheme: base.textTheme.copyWith(bodyMedium: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
    cardColor: AppColors.bgPanelAlt,
    dividerColor: AppColors.border,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgPanel,
      elevation: 0,
      titleTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: AppColors.bgPanelAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(AppColors.borderStrong),
      radius: const Radius.circular(8),
      thickness: WidgetStateProperty.all(12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.accent)),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border),
        foregroundColor: AppColors.textPrimary,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.bgPanelAlt,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.bgPanel),
  );
}
