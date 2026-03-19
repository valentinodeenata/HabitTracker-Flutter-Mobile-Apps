import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/routes/app_pages.dart';
import 'package:habit_flow/core/routes/app_routes.dart';
import 'package:habit_flow/core/services/notification_service.dart';
import 'package:habit_flow/core/services/storage_service.dart';
import 'package:habit_flow/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NotificationService().init());
  runApp(const HabitFlowApp());
}

class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.to;
    return GetMaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
