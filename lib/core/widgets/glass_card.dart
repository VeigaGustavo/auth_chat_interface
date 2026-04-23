import 'dart:ui';

import 'package:flutter/material.dart';

/// Liquid glass forte: blur alto + camadas de reflexo + borda luminosa.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  static const double _radius = 26;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 52,
            offset: const Offset(0, 24),
            spreadRadius: -14,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.09),
            blurRadius: 42,
            offset: const Offset(0, 12),
            spreadRadius: -22,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            // Base quase preta — “vidro” mais escuro que o fundo da página.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xF2050505),
                ),
              ),
            ),
            // Camada 1: desfoque do que está atrás (reflexos discretos em cima do preto)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.02),
                        Colors.white.withValues(alpha: 0.045),
                      ],
                      stops: const <double>[0.0, 0.48, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Camada 2: reflexo suave (bem mais subtil que antes)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.55, -0.85),
                      radius: 1.35,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.09),
                        Colors.white.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.38, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Camada 3: faixa superior discreta
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 72,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.white.withValues(alpha: 0.11),
                        Colors.white.withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                      stops: const <double>[0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Camada 4: rebordo
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.26),
                      width: 1.25,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
