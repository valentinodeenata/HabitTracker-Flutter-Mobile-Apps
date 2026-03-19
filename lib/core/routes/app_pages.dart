import 'package:get/get.dart';
import 'package:habit_flow/core/routes/app_routes.dart';
import 'package:habit_flow/core/views/splash_view.dart';
import 'package:habit_flow/features/focus_session/presentation/bindings/focus_session_binding.dart';
import 'package:habit_flow/features/focus_session/presentation/views/focus_session_view.dart';
import 'package:habit_flow/features/habit/presentation/bindings/habit_binding.dart';
import 'package:habit_flow/features/habit/presentation/views/add_edit_habit_view.dart';
import 'package:habit_flow/features/home/presentation/views/home_view.dart';
import 'package:habit_flow/features/settings/presentation/bindings/settings_binding.dart';
import 'package:habit_flow/features/settings/presentation/views/settings_view.dart';
import 'package:habit_flow/features/stats/presentation/bindings/stats_binding.dart';
import 'package:habit_flow/features/stats/presentation/views/stats_view.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HabitBinding(),
    ),
    GetPage(
      name: AppRoutes.addHabit,
      page: () => const AddEditHabitView(isEdit: false),
      binding: HabitBinding(),
    ),
    GetPage(
      name: AppRoutes.editHabit,
      page: () => const AddEditHabitView(isEdit: true),
      binding: HabitBinding(),
    ),
    GetPage(
      name: AppRoutes.focusSession,
      page: () => const FocusSessionView(),
      binding: FocusSessionBinding(),
    ),
    GetPage(
      name: AppRoutes.stats,
      page: () => const StatsView(),
      binding: StatsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
