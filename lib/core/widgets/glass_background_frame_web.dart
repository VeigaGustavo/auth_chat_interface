// Web-only: rAF nativo; `dart:html` continua a ser o caminho mais simples no app Flutter Web.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;

bool _glassBgFrameRun = false;

/// Loop com `requestAnimationFrame` do browser — no Web costuma ser o único jeito 100% fiável
/// de receber um callback **todo frame** sem depender do agendamento interno do Flutter.
void startGlassBackgroundFrameLoop(void Function(double timeMs) onFrame) {
  _glassBgFrameRun = true;
  void loop(num _) {
    if (!_glassBgFrameRun) {
      return;
    }
    onFrame(html.window.performance.now().toDouble());
    html.window.requestAnimationFrame(loop);
  }

  html.window.requestAnimationFrame(loop);
}

void stopGlassBackgroundFrameLoop() {
  _glassBgFrameRun = false;
}
