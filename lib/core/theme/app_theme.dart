import 'package:flutter/material.dart';

import 'app_monochrome.dart';

class AppTheme {
  /// Tema escuro: preto base, texto e contornos em branco / branco suave.
  static ThemeData get glassDarkTheme {
    const ColorScheme scheme = ColorScheme.dark(
      primary: AppMonochrome.white,
      onPrimary: AppMonochrome.bgDeep,
      surface: AppMonochrome.bgElevated,
      onSurface: AppMonochrome.ink,
      secondary: AppMonochrome.inkMuted,
      onSecondary: AppMonochrome.bgDeep,
      outline: AppMonochrome.line,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppMonochrome.bg,
      textTheme: const TextTheme().apply(
        bodyColor: AppMonochrome.ink,
        displayColor: AppMonochrome.ink,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppMonochrome.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppMonochrome.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppMonochrome.white, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: AppMonochrome.bgDeep,
          backgroundColor: AppMonochrome.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppMonochrome.white,
          foregroundColor: AppMonochrome.bgDeep,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppMonochrome.bgElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppMonochrome.line),
        ),
      ),
    );
  }
}
