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

  /// Drag & drop reordering for today's list only.
  ///
  /// We update the in-memory [habits] order so toggling completion won't
  /// reset the list ordering.
  void reorderTodayHabits(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;

    final weekday = app_utils.weekdayToday();
    final byId = {for (final h in habits) h.id: h};

    final currentToday = todayHabits.toList();
    if (oldIndex < 0 ||
        oldIndex >= currentToday.length ||
        newIndex < 0 ||
        newIndex >= currentToday.length) {
      return;
    }

    final ids = currentToday.map((e) => e.id).toList();
    final moved = ids.removeAt(oldIndex);
    ids.insert(newIndex, moved);

    var pointer = 0;
    final newHabits = habits.map((h) {
      if (!h.isScheduledOn(weekday)) return h;
      final nextId = ids[pointer++];
      return byId[nextId] ?? h;
    }).toList();

    habits.value = newHabits;
    // Recompute today view + logs from updated in-memory order.
    loadToday();
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
