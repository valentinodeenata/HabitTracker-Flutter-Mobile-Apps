import 'package:flutter/material.dart';

/// Centralized color palette for HabitFlow.
abstract class AppColors {
  // Primary
  // Slightly more mature indigo (production-friendly)
  static const Color primary = Color(0xFF5B5EF7);
  static const Color primaryLight = Color(0xFF7C7DFF);
  static const Color primaryDark = Color(0xFF4447E6);

  // Surface (light)
  static const Color surfaceLight = Color(0xFFF7F8FF);
  static const Color surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF0F172A);
  static const Color onSurfaceVariantLight = Color(0xFF64748B);

  // Surface (dark)
  static const Color surfaceDark = Color(0xFF020617);
  static const Color surfaceContainerDark = Color(0xFF0B1020);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color onSurfaceVariantDark = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Habit preset colors
  static const List<Color> habitColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFFEC4899), // pink
    Color(0xFF14B8A6), // teal
    Color(0xFFF59E0B), // amber
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
    Color(0xFF22C55E), // green
    Color(0xFFEF4444), // red
  ];
}
