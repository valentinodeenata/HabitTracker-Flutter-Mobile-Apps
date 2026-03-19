/// Date helpers for habit tracking.
String todayKey() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

int weekdayToday() {
  // Dart: 1 = Monday, 7 = Sunday
  return DateTime.now().weekday;
}
