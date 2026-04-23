import 'package:flutter/material.dart';

/// Logo principal da app (PNG em [branding/app_logo.png]).
///
/// O caminho **não** usa a pasta `assets/` no nome do asset: no Flutter Web o
/// runtime já prefixa `assets/`, e `assets/images/...` gerava URL `assets/assets/...`.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.fit = BoxFit.contain,
    this.borderRadius,
  });

  static const String assetPath = 'branding/app_logo.png';

  final double size;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Chat VeigaGustavo',
      gaplessPlayback: true,
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }
    return image;
  }
}
