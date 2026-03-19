import 'package:get/get.dart';
import 'package:habit_flow/core/utils/date_utils.dart' as app_utils;
import 'package:habit_flow/features/habit/data/habit_log_model.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/data/habit_repository.dart';

class HabitController extends GetxController {
  final HabitRepository _repo = HabitRepository();

  final RxList<HabitModel> habits = <HabitModel>[].obs;
  final RxList<HabitModel> todayHabits = <HabitModel>[].obs;
  final RxMap<String, HabitLogModel> todayLogs = <String, HabitLogModel>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadHabits();
    loadToday();
  }

  void loadHabits() {
    habits.value = _repo.getAllHabits();
  }

  void loadToday() {
    loadHabits();
    final today = app_utils.todayKey();
    final weekday = app_utils.weekdayToday();
    todayHabits.value =
        habits.where((h) => h.isScheduledOn(weekday)).toList();
    final logs = _repo.getAllLogs().where((l) => l.date == today);
    todayLogs.clear();
    for (final l in logs) {
      todayLogs[l.habitId] = l;
    }
  }

  bool isCompletedToday(String habitId) {
    return todayLogs[habitId]?.completed ?? false;
  }

  int getStreak(String habitId) => _repo.getStreak(habitId);

  Future<void> toggleComplete(String habitId) async {
    final today = app_utils.todayKey();
    final already = todayLogs[habitId];
    if (already != null && already.completed) {
      final logs = _repo.getAllLogs()
          .where((e) => !(e.habitId == habitId && e.date == today))
          .toList();
      await _repo.replaceLogs(logs);
    } else {
      await _repo.addLog(HabitLogModel(habitId: habitId, date: today, completed: true, completedAt: DateTime.now()));
    }
    loadToday();
  }

  Future<void> completeWithFocus(String habitId, int focusMinutes) async {
    final today = app_utils.todayKey();
    await _repo.addLog(HabitLogModel(
      habitId: habitId,
      date: today,
      completed: true,
      completedAt: DateTime.now(),
      focusMinutes: focusMinutes,
    ));
    loadToday();
  }

  Future<void> addHabit(HabitModel habit) async {
    await _repo.addHabit(habit);
    loadHabits();
    loadToday();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _repo.updateHabit(habit);
    loadHabits();
    loadToday();
  }

  Future<void> deleteHabit(String habitId) async {
    await _repo.deleteHabit(habitId);
    loadHabits();
    loadToday();
  }

  HabitModel? getHabit(String id) {
    for (final h in habits) {
      if (h.id == id) return h;
    }
    return null;
  }
}
