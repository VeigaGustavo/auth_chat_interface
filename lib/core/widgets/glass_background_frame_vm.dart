import 'package:flutter/scheduler.dart';

bool _glassBgFrameRun = false;

/// Loop de frames via engine Flutter (VM / mobile / desktop).
void startGlassBackgroundFrameLoop(void Function(double timeMs) onFrame) {
  _glassBgFrameRun = true;
  void onSchedulerFrame(Duration timeStamp) {
    if (!_glassBgFrameRun) {
      return;
    }
    onFrame(timeStamp.inMicroseconds / 1000.0);
    SchedulerBinding.instance.scheduleFrameCallback(onSchedulerFrame);
  }

  SchedulerBinding.instance.scheduleFrameCallback(onSchedulerFrame);
}

void stopGlassBackgroundFrameLoop() {
  _glassBgFrameRun = false;
}
