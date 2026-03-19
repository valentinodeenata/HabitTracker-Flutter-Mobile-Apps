import 'package:get/get.dart';
import 'package:habit_flow/features/habit/data/habit_log_model.dart';
import 'package:habit_flow/features/habit/data/habit_model.dart';
import 'package:habit_flow/features/habit/data/habit_repository.dart';

class StatsController extends GetxController {
  final HabitRepository _repo = HabitRepository();

  List<HabitModel> get habits => _repo.getAllHabits();
  List<HabitLogModel> get logs => _repo.getAllLogs();

  int get totalFocusMinutes =>
      logs.fold(0, (sum, l) => sum + (l.focusMinutes ?? 0));

  Map<String, int> completionByDateLast7Days() {
    final today = DateTime.now();
    final result = <String, int>{};
    for (var i = 0; i < 7; i++) {
      final d = today.subtract(Duration(days: i));
      final key2 = _dateKey(d);
      result[key2] = logs.where((l) => l.date == key2 && l.completed).length;
    }
    return result;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<MapEntry<String, int>> last7DaysCompletions() {
    final today = DateTime.now();
    final list = <MapEntry<String, int>>[];
    for (var i = 6; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final key = _dateKey(d);
      final count = logs.where((l) => l.date == key && l.completed).length;
      list.add(MapEntry(key, count));
    }
    return list;
  }

  int getStreak(String habitId) => _repo.getStreak(habitId);
}
