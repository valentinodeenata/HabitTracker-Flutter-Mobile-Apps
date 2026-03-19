/// One completion record for a habit on a given date.
class HabitLogModel {
  final String habitId;
  final String date; // YYYY-MM-DD
  final bool completed;
  final DateTime? completedAt;
  final int? focusMinutes; // from focus session

  const HabitLogModel({
    required this.habitId,
    required this.date,
    this.completed = true,
    this.completedAt,
    this.focusMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'focusMinutes': focusMinutes,
    };
  }

  factory HabitLogModel.fromMap(Map<String, dynamic> map) {
    return HabitLogModel(
      habitId: map['habitId'] as String,
      date: map['date'] as String,
      completed: map['completed'] as bool? ?? true,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      focusMinutes: map['focusMinutes'] as int?,
    );
  }
}
