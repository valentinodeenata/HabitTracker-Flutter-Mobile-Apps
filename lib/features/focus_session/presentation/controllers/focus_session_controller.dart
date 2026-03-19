import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/presentation/controllers/habit_controller.dart';

class FocusSessionController extends GetxController {
  final HabitController habitController = Get.find<HabitController>();

  final Rx<HabitModel?> habit = Rx<HabitModel?>(null);
  final RxInt remainingSeconds = 0.obs;
  final RxBool isRunning = false.obs;
  final RxBool isPaused = false.obs;

  Timer? _timer;
  int _totalSeconds = 0;
  int _elapsedSeconds = 0;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is HabitModel) {
      habit.value = arg;
      // Default 25 min focus session
      setDurationMinutes(25);
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void setDurationMinutes(int minutes) {
    _totalSeconds = minutes * 60;
    remainingSeconds.value = _totalSeconds;
    _elapsedSeconds = 0;
  }

  void start() {
    if (habit.value == null) return;
    _timer?.cancel();
    isRunning.value = true;
    isPaused.value = false;

    final h = habit.value!;

    // Start timer immediately so countdown can't get blocked by notif scheduling.
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

    // Schedule system notification (best-effort).
    // Even if notification scheduling fails, the timer should keep running.
    try {
      // Delay one frame so UI/timer update can't be blocked.
      final after = Duration(seconds: remainingSeconds.value);
      Future.delayed(Duration.zero, () {
        NotificationService.to.scheduleFocusDone(
          habitId: h.id,
          habitName: h.name,
          after: after,
        );
      });
    } catch (_) {
      // Notification failures shouldn't break focus session UX.
    }
  }

  void _completeSession() {
    final h = habit.value;
    if (h == null) return;
    NotificationService.to.cancelFocusDone(h.id);
    final minutes = (_elapsedSeconds / 60).ceil();
    habitController.completeWithFocus(h.id, minutes);
    Get.back();
    Get.snackbar(
      'Focus complete',
      '${h.name}: $minutes min logged',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withValues(alpha: 0.95),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  void pause() {
    isPaused.value = true;
    _timer?.cancel();
    final h = habit.value;
    if (h != null) NotificationService.to.cancelFocusDone(h.id);
  }

  void resume() {
    isPaused.value = false;
    start();
  }

  void stop() {
    _timer?.cancel();
    isRunning.value = false;
    isPaused.value = false;
    final h = habit.value;
    if (h != null) NotificationService.to.cancelFocusDone(h.id);
    Get.back();
  }

  /// 00:00 formatted remaining time
  String get formattedTime {
    final s = remainingSeconds.value;
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  /// 0.0 - 1.0 progress of the current session.
  double get progress {
    if (_totalSeconds == 0) return 0;
    final done = _elapsedSeconds / _totalSeconds;
    if (done.isNaN || done.isInfinite) return 0;
    return done.clamp(0.0, 1.0);
  }

  int get totalMinutes => _totalSeconds ~/ 60;

  int get elapsedMinutes => (_elapsedSeconds / 60).floor();
}
