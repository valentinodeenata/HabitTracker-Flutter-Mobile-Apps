import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

const String _kFocusHabitNameKey = 'focus.habitName';
const String _kFocusEndsAtMillisKey = 'focus.endsAtMillis';

@pragma('vm:entry-point')
void focusStartCallback() {
  FlutterForegroundTask.setTaskHandler(FocusTaskHandler());
}

class FocusTaskHandler extends TaskHandler {
  String? _habitName;
  int? _endsAtMillis;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final name = await FlutterForegroundTask.getData(key: _kFocusHabitNameKey);
    final ends = await FlutterForegroundTask.getData(key: _kFocusEndsAtMillisKey);

    _habitName = name is String ? name : null;
    _endsAtMillis = ends is int ? ends : null;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final endsAtMillis = _endsAtMillis;
    if (endsAtMillis == null) return;

    final remainingMs = endsAtMillis - DateTime.now().millisecondsSinceEpoch;
    final remainingSec = (remainingMs / 1000).ceil().clamp(0, 24 * 60 * 60);
    final m = remainingSec ~/ 60;
    final s = remainingSec % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');

    final name = _habitName ?? 'Focus';
    unawaited(
      FlutterForegroundTask.updateService(
        notificationTitle: 'Focus running',
        notificationText: '$name • $mm:$ss left',
      ),
    );
  }

  @override
  void onReceiveData(Object data) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

