enum HabitCategory {
  coding,
  reading,
  walking,
  run,
  swimming,
  prayer,
  study,
  gaming,
  haveFun,
}

HabitCategory habitCategoryFromString(String? value) {
  if (value == null) return HabitCategory.haveFun;
  return HabitCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => HabitCategory.haveFun,
  );
}

