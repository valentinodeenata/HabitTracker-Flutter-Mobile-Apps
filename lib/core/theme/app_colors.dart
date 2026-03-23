import 'package:flutter/material.dart';

/// Palette aligned with the HabitFlow logo: deep teal → mint gradient, white surfaces.
abstract class AppColors {
  // Logo core
  static const Color tealDeep = Color(0xFF004D56);
  static const Color teal = Color(0xFF006064);
  static const Color tealMid = Color(0xFF26A69A);
  static const Color mint = Color(0xFF80CBC4);
  static const Color mintLight = Color(0xFFB2DFDB);
  static const Color mintPale = Color(0xFFE0F2F1);

  /// Primary actions (readable on white / light surfaces)
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF00695C);

  // Surfaces — light (soft mint-white)
  static const Color surfaceLight = Color(0xFFF8FCFB);
  static const Color surfaceContainerLight = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF1A2E2E);
  static const Color onSurfaceVariantLight = Color(0xFF5C7172);

  // Surfaces — dark (deep teal night)
  static const Color surfaceDark = Color(0xFF061A1C);
  static const Color surfaceContainerDark = Color(0xFF0E2A2D);
  static const Color onSurfaceDark = Color(0xFFE8F5F4);
  static const Color onSurfaceVariantDark = Color(0xFF9DB5B5);

  // Semantic
  static const Color success = Color(0xFF2E7D6A);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFE08D12);

  /// Brand gradient (logo-style: deep teal → mint)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: <Color>[
      tealDeep,
      tealMid,
      mintLight,
    ],
    stops: <double>[0.0, 0.5, 1.0],
  );

  /// Subtle wash for hero / splash backgrounds
  static const LinearGradient surfaceGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFFF0FAF8),
      Color(0xFFFFFFFF),
      Color(0xFFE8F6F4),
    ],
  );

  static const LinearGradient surfaceGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      Color(0xFF03191C),
      Color(0xFF0A2E32),
      Color(0xFF061A1C),
    ],
  );

  /// Bar chart / accents
  static const LinearGradient chartBarGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: <Color>[
      tealDeep,
      tealMid,
    ],
  );

  // Habit chips — cohesive with teal family + soft accents
  static const List<Color> habitColors = <Color>[
    Color(0xFF00897B),
    Color(0xFF26A69A),
    Color(0xFF4DB6AC),
    Color(0xFF78909C),
    Color(0xFF5C6BC0),
    Color(0xFFEC8B9C),
    Color(0xFFFFB74D),
    Color(0xFF7E57C2),
  ];
}
