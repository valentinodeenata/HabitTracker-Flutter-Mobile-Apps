import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storage = StorageService.to;

  bool get isDarkMode => _storage.isDarkMode;
  bool get notificationsEnabled => _storage.notificationsEnabled;
  String get focusCompleteSound => _storage.focusCompleteSound;

  void setDarkMode(bool value) {
    _storage.isDarkMode = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    update();
  }

  void setNotificationsEnabled(bool value) {
    _storage.notificationsEnabled = value;
    update();
  }

  void setFocusCompleteSound(String value) {
    _storage.focusCompleteSound = value;
    update();
  }
}
