import 'package:flutter/material.dart';
import 'package:habit_flow/features/habit/data/habit_category.dart';

enum HabitFrequency { daily, custom }

/// Model for a single habit.
class HabitModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int> customDays; // 1 = Monday .. 7 = Sunday
  final int dailyTarget; // e.g. 1 = once per day
  final DateTime createdAt;
  final TimeOfDay? reminderTime;

  const HabitModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.category = HabitCategory.haveFun,
    required this.frequency,
    this.customDays = const [],
    this.dailyTarget = 1,
    required this.createdAt,
    this.reminderTime,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  bool isScheduledOn(int weekday) {
    if (frequency == HabitFrequency.daily) return true;
    return customDays.contains(weekday);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'category': category.name,
      'frequency': frequency.name,
      'customDays': customDays,
      'dailyTarget': dailyTarget,
      'createdAt': createdAt.toIso8601String(),
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminder;
    final h = map['reminderHour'], m = map['reminderMinute'];
    if (h != null && m != null) reminder = TimeOfDay(hour: h as int, minute: m as int);
    return HabitModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconCodePoint: map['iconCodePoint'] as int,
      colorValue: map['colorValue'] as int,
      category: habitCategoryFromString(map['category'] as String?),
      frequency: HabitFrequency.values.byName(map['frequency'] as String? ?? 'daily'),
      customDays: List<int>.from(map['customDays'] as List? ?? []),
      dailyTarget: map['dailyTarget'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      reminderTime: reminder,
    );
  }

  HabitModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? customDays,
    int? dailyTarget,
    DateTime? createdAt,
    TimeOfDay? reminderTime,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      customDays: customDays ?? this.customDays,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      createdAt: createdAt ?? this.createdAt,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
