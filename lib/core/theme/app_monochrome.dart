import 'package:flutter/material.dart';

/// Preto como base; **branco** para texto, bordas e realces (liquid glass escuro).
abstract final class AppMonochrome {
  static const Color bg = Color(0xFF030303);
  static const Color bgDeep = Color(0xFF000000);
  static const Color bgElevated = Color(0xFF0A0A0A);

  static const Color white = Color(0xFFFFFFFF);

  /// Texto / ícones principais.
  static const Color ink = Color(0xFFFFFFFF);
  /// Secundário.
  static const Color inkMuted = Color(0xFFC8C8C8);
  static const Color inkSubtle = Color(0xFF909090);

  /// Superfície chip / áreas levantadas (quase preto).
  static const Color paper = Color(0xFF030303);
  static const Color paper2 = Color(0xFF0E0E0E);

  /// Bordas e linhas (branco translúcido).
  static const Color line = Color(0x33FFFFFF);
  static const Color lineLight = Color(0x1AFFFFFF);
}
