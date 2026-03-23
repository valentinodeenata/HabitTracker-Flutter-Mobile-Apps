import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/routes/app_routes.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:habit_flow/features/focus_session/presentation/widgets/focus_complete_dialog.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';

/// Holds focus timer state for the whole app lifecycle. Registered with
/// [permanent: true] so leaving the focus route does not dispose the session
/// (matches Android foreground service / notifications).
class FocusSessionController extends GetxController {
  final HabitController habitController = Get.find<HabitController>();

  final Rx<HabitModel?> habit = Rx<HabitModel?>(null);
  final RxInt remainingSeconds = 0.obs;
  final RxBool isRunning = false.obs;
  final RxBool isPaused = false.obs;

  Timer? _timer;
  int _totalSeconds = 0;
  int _elapsedSeconds = 0;

  /// Called from [FocusSessionBinding] whenever the focus route opens.
  void syncRouteArguments(dynamic arguments) {
    if (arguments is! HabitModel) return;

    if (isRunning.value || isPaused.value) {
      if (habit.value?.id == arguments.id) {
        return;
      }
      Get.snackbar(
        'Focus in progress',
        'Stop or finish your current session (${habit.value?.name ?? "focus"}) before starting another.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    habit.value = arguments;
    setDurationMinutes(25);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setDurationMinutes(int minutes) {
    if (isRunning.value || isPaused.value) return;
    _totalSeconds = minutes * 60;
    remainingSeconds.value = _totalSeconds;
    _elapsedSeconds = 0;
  }

  void start() {
    if (habit.value == null) return;
    if (isRunning.value && !isPaused.value) return;

    final wasPaused = isPaused.value;

    _timer?.cancel();
    isRunning.value = true;
    isPaused.value = false;

    final h = habit.value!;
    final endsAt = DateTime.now().add(Duration(seconds: remainingSeconds.value));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value <= 0) {
        _timer?.cancel();
        isRunning.value = false;
        _completeSession();
        return;
      }
      remainingSeconds.value--;
      _elapsedSeconds++;
    });

    try {
      final after = Duration(seconds: remainingSeconds.value);
      Future.delayed(Duration.zero, () async {
        if (!wasPaused) {
          await NotificationService.to.showFocusStarted(
            habitId: h.id,
            habitName: h.name,
            minutes: totalMinutes,
          );
        }

        final fgsStarted = await NotificationService.to.startFocusForeground(
          habitName: h.name,
          endsAt: endsAt,
        );

        if (!fgsStarted) {
          await NotificationService.to.showFocusRunning(
            habitId: h.id,
            habitName: h.name,
            endsAt: endsAt,
          );
        }

        await NotificationService.to.scheduleFocusDone(
          habitId: h.id,
          habitName: h.name,
          after: after,
        );
      });
    } catch (_) {}
  }

  void _completeSession() {
    final h = habit.value;
    if (h == null) return;
    final habitId = h.id;
    final habitName = h.name;
    final minutes = (_elapsedSeconds / 60).ceil();

    NotificationService.to.stopFocusForeground();
    NotificationService.to.cancelFocusRunning(habitId);
    NotificationService.to.cancelFocusStarted(habitId);
    NotificationService.to.cancelFocusDone(habitId);

    habitController.completeWithFocus(habitId, minutes);
    _clearSessionState();
    if (Get.currentRoute == AppRoutes.focusSession) {
      Get.back();
    }

    unawaited(_presentFocusCompleteFeedback(habitId, habitName, minutes));
  }

  Future<void> _presentFocusCompleteFeedback(
    String habitId,
    String habitName,
    int minutes,
  ) async {
    await Future<void>.delayed(Duration.zero);
    if (kIsWeb) {
      Get.snackbar(
        'Focus complete',
        '$habitName: ${minutes == 1 ? '1 minute' : '$minutes minutes'} logged',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      await NotificationService.to.showFocusCompleteNow(
        habitId: habitId,
        habitName: habitName,
        minutesLogged: minutes,
      );
    }
    final label = minutes == 1 ? '1 minute' : '$minutes minutes';
    if (Get.context != null) {
      await Get.dialog<void>(
        FocusCompleteDialog(habitName: habitName, minutesLabel: label),
        barrierDismissible: true,
      );
    }
  }

  void _clearSessionState() {
    _timer?.cancel();
    _timer = null;
    habit.value = null;
    remainingSeconds.value = 0;
    _elapsedSeconds = 0;
    _totalSeconds = 0;
    isRunning.value = false;
    isPaused.value = false;
  }

  void pause() {
    isPaused.value = true;
    _timer?.cancel();
    final h = habit.value;
    if (h != null) {
      NotificationService.to.stopFocusForeground();
      NotificationService.to.cancelFocusRunning(h.id);
      NotificationService.to.cancelFocusDone(h.id);
    }
  }

  void resume() {
    if (!isPaused.value) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    final h = habit.value;
    if (h != null) {
      NotificationService.to.stopFocusForeground();
      NotificationService.to.cancelFocusRunning(h.id);
      NotificationService.to.cancelFocusDone(h.id);
    }
    _clearSessionState();
    Get.back();
  }

  String get formattedTime {
    final s = remainingSeconds.value;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_totalSeconds == 0) return 0;
    final done = _elapsedSeconds / _totalSeconds;
    if (done.isNaN || done.isInfinite) return 0;
    return done.clamp(0.0, 1.0);
  }

  int get totalMinutes => _totalSeconds ~/ 60;

  int get elapsedMinutes => (_elapsedSeconds / 60).floor();
}
