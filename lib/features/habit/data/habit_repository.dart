import 'package:habit_flow/core/constants/storage_keys.dart';
import 'package:habit_flow/core/services/storage_service.dart';
import 'package:habit_flow/features/habit/data/habit_log_model.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';

class HabitRepository {
  final StorageService _storage = StorageService.to;

  List<HabitModel> getAllHabits() {
    final list = _storage.habitsBox.get(StorageKeys.habits);
    if (list == null) return [];
    return (list as List)
        .map((e) => HabitModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    await _storage.habitsBox.put(
      StorageKeys.habits,
      habits.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> addHabit(HabitModel habit) async {
    final list = getAllHabits();
    list.add(habit);
    await saveHabits(list);
  }

  Future<void> updateHabit(HabitModel habit) async {
    final list = getAllHabits();
    final i = list.indexWhere((e) => e.id == habit.id);
    if (i >= 0) {
      list[i] = habit;
      await saveHabits(list);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final list = getAllHabits().where((e) => e.id != habitId).toList();
    await saveHabits(list);
    await _deleteLogsForHabit(habitId);
  }

  List<HabitLogModel> getAllLogs() {
    final list = _storage.habitLogsBox.get(StorageKeys.habitLogs);
    if (list == null) return [];
    return (list as List)
        .map((e) => HabitLogModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveLogs(List<HabitLogModel> logs) async {
    await _storage.habitLogsBox.put(
      StorageKeys.habitLogs,
      logs.map((e) => e.toMap()).toList(),
    );
  }

  Future<void> replaceLogs(List<HabitLogModel> logs) async {
    await _saveLogs(logs);
  }

  Future<void> addLog(HabitLogModel log) async {
    final logs = getAllLogs();
    final existing = logs.indexWhere(
      (e) => e.habitId == log.habitId && e.date == log.date,
    );
    if (existing >= 0) {
      logs[existing] = log;
    } else {
      logs.add(log);
    }
    await _saveLogs(logs);
  }

  HabitLogModel? getLog(String habitId, String date) {
    return getAllLogs().cast<HabitLogModel?>().firstWhere(
          (e) => e?.habitId == habitId && e?.date == date,
          orElse: () => null,
        );
  }

  List<HabitLogModel> getLogsForHabit(String habitId) {
    return getAllLogs().where((e) => e.habitId == habitId).toList();
  }

  Future<void> _deleteLogsForHabit(String habitId) async {
    final logs = getAllLogs().where((e) => e.habitId != habitId).toList();
    await _saveLogs(logs);
  }

  /// Consecutive days completed up to today.
  int getStreak(String habitId) {
    final completedDates = getLogsForHabit(habitId)
        .where((e) => e.completed)
        .map((e) => e.date)
        .toSet();
    if (completedDates.isEmpty) return 0;
    var current = DateTime.now();
    final today = DateTime(current.year, current.month, current.day);
    if (!completedDates.contains(_dateKey(today))) return 0;
    int streak = 0;
    var day = today;
    while (completedDates.contains(_dateKey(day))) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
