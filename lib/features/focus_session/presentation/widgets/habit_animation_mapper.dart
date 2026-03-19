import 'package:habit_flow/features/habit/data/habit_category.dart';

/// Maps a habit category to a Lottie animation asset path.
String lottieForCategory(HabitCategory category) {
  if (category == HabitCategory.coding) {
    return 'assets/animations/coding.json';
  }
  if (category == HabitCategory.reading) {
    return 'assets/animations/reading.json';
  }
  if (category == HabitCategory.walking) {
    return 'assets/animations/walking.json';
  }
  if (category == HabitCategory.run) {
    return 'assets/animations/run.json';
  }
  if (category == HabitCategory.swimming) {
    return 'assets/animations/swimming.json';
  }
  if (category == HabitCategory.prayer) {
    return 'assets/animations/prayer.json';
  }
  if (category == HabitCategory.study) {
    return 'assets/animations/study.json';
  }
  if (category == HabitCategory.gaming) {
    return 'assets/animations/gaming.json';
  }
  return 'assets/animations/have_fun.json';
}

