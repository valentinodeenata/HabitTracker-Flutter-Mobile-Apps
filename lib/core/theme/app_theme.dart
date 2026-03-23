import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_flow/core/theme/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme().apply(
          bodyColor: AppColors.onSurfaceLight,
          displayColor: AppColors.onSurfaceLight,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: Color(0xFFFFFFFF),
          primaryContainer: AppColors.mintPale,
          onPrimaryContainer: AppColors.tealDeep,
          secondary: AppColors.tealMid,
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: AppColors.mintLight,
          onSecondaryContainer: AppColors.tealDeep,
          tertiary: AppColors.mint,
          onTertiary: AppColors.tealDeep,
          error: AppColors.error,
          onError: Color(0xFFFFFFFF),
          surface: AppColors.surfaceLight,
          onSurface: AppColors.onSurfaceLight,
          surfaceContainerHighest: Color(0xFFE8F2F0),
          onSurfaceVariant: AppColors.onSurfaceVariantLight,
          outline: Color(0xFFB8C9C7),
          outlineVariant: Color(0xFFDCE8E6),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: AppColors.tealDeep,
          onInverseSurface: Color(0xFFE8F5F4),
          inversePrimary: AppColors.mintLight,
        ),
        scaffoldBackgroundColor: AppColors.surfaceLight,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.onSurfaceLight,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.onSurfaceLight,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.onSurfaceVariantLight,
            size: 22,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariantLight,
          size: 22,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: AppColors.surfaceContainerLight,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 3,
          focusElevation: 5,
          hoverElevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
            foregroundColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFFB8C9C7)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F7F6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD0DEDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return null;
          }),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary.withValues(alpha: 0.45);
            }
            return null;
          }),
        ),
        dividerTheme: DividerThemeData(
          color: const Color(0xFFDCE8E6).withValues(alpha: 0.9),
          thickness: 1,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          ThemeData(brightness: Brightness.dark, useMaterial3: true).textTheme,
        ).apply(
          bodyColor: AppColors.onSurfaceDark,
          displayColor: AppColors.onSurfaceDark,
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.mint,
          onPrimary: Color(0xFF00302C),
          primaryContainer: Color(0xFF1A4A4F),
          onPrimaryContainer: AppColors.mintLight,
          secondary: AppColors.tealMid,
          onSecondary: Color(0xFFFFFFFF),
          secondaryContainer: Color(0xFF1E4A4F),
          onSecondaryContainer: AppColors.mintLight,
          tertiary: AppColors.mintLight,
          onTertiary: AppColors.tealDeep,
          error: Color(0xFFFFB4AB),
          onError: Color(0xFF690005),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
          surfaceContainerHighest: Color(0xFF1A3F44),
          onSurfaceVariant: AppColors.onSurfaceVariantDark,
          outline: Color(0xFF4A6568),
          outlineVariant: Color(0xFF2D4548),
          shadow: Color(0xFF000000),
          scrim: Color(0xFF000000),
          inverseSurface: AppColors.mintPale,
          onInverseSurface: AppColors.tealDeep,
          inversePrimary: AppColors.teal,
        ),
        scaffoldBackgroundColor: AppColors.surfaceDark,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.onSurfaceDark,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: AppColors.onSurfaceDark,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.onSurfaceVariantDark,
            size: 22,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.onSurfaceVariantDark,
          size: 22,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: AppColors.surfaceContainerDark,
          surfaceTintColor: Colors.transparent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.mint,
          foregroundColor: Color(0xFF00302C),
          elevation: 3,
          focusElevation: 5,
          hoverElevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ).copyWith(
            backgroundColor: const WidgetStatePropertyAll(AppColors.mint),
            foregroundColor: const WidgetStatePropertyAll(Color(0xFF00302C)),
            overlayColor: WidgetStatePropertyAll(
              Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: Color(0xFF4A6568)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A3F44),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF2D4548)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: const BorderSide(color: Color(0xFF2D4548)),
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.mint;
            }
            return null;
          }),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.mint;
            }
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.mint.withValues(alpha: 0.45);
            }
            return null;
          }),
        ),
        dividerTheme: DividerThemeData(
          color: const Color(0xFF2D4548).withValues(alpha: 0.9),
          thickness: 1,
        ),
      );
}
