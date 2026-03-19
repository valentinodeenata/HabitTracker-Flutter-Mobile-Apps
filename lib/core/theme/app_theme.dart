import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_flow/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: Color(0xFF14B8A6),
          onSecondary: Colors.white,
          error: AppColors.error,
          onError: Colors.white,
          surface: Color(0xFFF7F8FF),
          onSurface: Color(0xFF0B1220),
          // Used by cards & controls via surfaceContainerHighest
          surfaceContainerHighest: Color(0xFFEEF0F6),
          onSurfaceVariant: Color(0xFF586174),
          outline: Color(0xFFD3D7E3),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFF0B1220),
          onInverseSurface: Colors.white,
          inversePrimary: Color(0xFFA9ABFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FF),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: const Color(0xFFF7F8FF),
          foregroundColor: AppColors.onSurfaceLight,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFFFFFFFF),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ).copyWith(
            backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEEF0F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD3D7E3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF7C7DFF),
          onPrimary: Colors.white,
          secondary: Color(0xFF2DD4BF),
          onSecondary: Color(0xFF071013),
          error: AppColors.error,
          onError: Colors.white,
          surface: Color(0xFF070A12),
          onSurface: Color(0xFFEAF0FF),
          surfaceContainerHighest: Color(0xFF151E36),
          onSurfaceVariant: Color(0xFFA8B0C5),
          outline: Color(0xFF2A3553),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: Color(0xFFEAF0FF),
          onInverseSurface: Color(0xFF070A12),
          inversePrimary: Color(0xFF5B5EF7),
        ),
        scaffoldBackgroundColor: const Color(0xFF070A12),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: Color(0xFF070A12),
          foregroundColor: AppColors.onSurfaceDark,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: const Color(0xFF0B1020),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFF7C7DFF),
          foregroundColor: Colors.white,
          elevation: 4,
          focusElevation: 6,
          hoverElevation: 6,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ).copyWith(
            backgroundColor: const WidgetStatePropertyAll(Color(0xFF7C7DFF)),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF151E36),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A3553)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF7C7DFF), width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFF2A3553)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      );
}
