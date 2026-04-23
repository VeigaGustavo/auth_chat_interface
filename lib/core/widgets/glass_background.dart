import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'glass_background_frame.dart';

/// Fundo monocromático com movimento contínuo.
///
/// O conteúdo ([child]) fica **fora** do `setState` do fundo.
///
/// No **Web**, o loop usa `requestAnimationFrame` do browser ([glass_background_frame_web]) —
/// o motor do Flutter nem sempre agenda frames contínuos sozinho; o rAF garante callback
/// em todo frame de pintura do Chrome.
class GlassBackground extends StatelessWidget {
  const GlassBackground({
    required this.child,
    super.key,
  });

  final Widget child;

  static const Color seaBackdrop = Color(0xFF131313);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _MonoBackdropLayers(),
        RepaintBoundary(
          child: SafeArea(child: child),
        ),
      ],
    );
  }
}

class _MonoBackdropLayers extends StatefulWidget {
  const _MonoBackdropLayers();

  @override
  State<_MonoBackdropLayers> createState() => _MonoBackdropLayersState();
}

class _MonoBackdropLayersState extends State<_MonoBackdropLayers> {
  /// ~12 s por ciclo — movimento perceptível sem ser frenético.
  static const double _omega = 2 * math.pi / 12;

  /// Tempo do último frame (ms), vindo do rAF no Web ou do scheduler na VM.
  double _timeMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      startGlassBackgroundFrameLoop((double timeMs) {
        if (!mounted) {
          return;
        }
        setState(() => _timeMs = timeMs);
      });
    });
  }

  @override
  void dispose() {
    stopGlassBackgroundFrameLoop();
    super.dispose();
  }

  double get _phase => (_timeMs / 1000.0) * _omega;

  @override
  Widget build(BuildContext context) {
    final double phase = _phase;
    final double phase2 = phase * 0.73 + 1.05;

    return TickerMode(
      enabled: true,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: <double>[0.0, 0.25, 0.52, 0.78, 1.0],
            colors: <Color>[
              Color(0xFF6A6A6A),
              Color(0xFF4A4A4A),
              Color(0xFF353535),
              Color(0xFF1E1E1E),
              Color(0xFF101010),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.9, -0.15),
                    end: Alignment(0.95, 0.35),
                    colors: <Color>[
                      Color(0x18FFFFFF),
                      Color(0x00000000),
                      Color(0x12000000),
                    ],
                    stops: <double>[0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.1, -0.92),
                    radius: 1.5,
                    colors: <Color>[
                      Color(0x66FFFFFF),
                      Color(0x22FFFFFF),
                      Color(0x00000000),
                    ],
                    stops: <double>[0.0, 0.32, 1.0],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                willChange: true,
                painter: _MonoWavesPainter(
                  phase: phase,
                  phase2: phase2,
                ),
              ),
            ),
            Positioned(
              top: -70 + 46 * math.sin(phase * 0.55),
              right: -50 + 38 * math.cos(phase * 0.42),
              child: _monoGlow(
                320,
                <Color>[
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.07),
                  Colors.transparent,
                ],
              ),
            ),
            Positioned(
              bottom: -90 + 36 * math.sin(phase * 0.48 + 1.2),
              left: -70 + 32 * math.cos(phase * 0.51 + 0.6),
              child: _monoGlow(
                360,
                <Color>[
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.12),
                  radius: 1.42,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monoGlow(double size, List<Color> colors) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 88, sigmaY: 88),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _MonoWavesPainter extends CustomPainter {
  _MonoWavesPainter({
    required this.phase,
    required this.phase2,
  });

  final double phase;
  final double phase2;

  static double _y(double x, double w, double base, double amp, double cycles, double ph) {
    return base + amp * math.sin((x / w) * math.pi * 2 * cycles + ph);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    void band({
      required double centerY,
      required double thickness,
      required double amp,
      required double cycles,
      required double phA,
      required double phB,
      required double opacity,
    }) {
      final Path path = Path();
      double top(double x) => _y(x, w, centerY - thickness * 0.5, amp, cycles, phA);
      double bot(double x) => _y(x, w, centerY + thickness * 0.5, amp * 0.65, cycles * 1.02, phB);

      path.moveTo(0, top(0));
      for (double x = 0; x <= w; x += 2) {
        path.lineTo(x, top(x));
      }
      for (double x = w; x >= 0; x -= 2) {
        path.lineTo(x, bot(x));
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    }

    band(
      centerY: h * 0.42,
      thickness: h * 0.14,
      amp: 14,
      cycles: 1.08,
      phA: phase,
      phB: phase2,
      opacity: 0.095,
    );
    band(
      centerY: h * 0.68,
      thickness: h * 0.16,
      amp: 18,
      cycles: 0.88,
      phA: phase + 2.3,
      phB: phase2 - 0.55,
      opacity: 0.075,
    );
  }

  @override
  bool shouldRepaint(covariant _MonoWavesPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.phase2 != phase2;
  }
}
