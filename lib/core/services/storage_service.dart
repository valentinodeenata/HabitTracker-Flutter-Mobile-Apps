import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habit_flow/core/constants/storage_keys.dart';

/// Handles Hive initialization and generic key-value storage.
class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  Box<dynamic>? _habitsBox;
  Box<dynamic>? _habitLogsBox;
  Box<dynamic>? _settingsBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();
    _habitsBox = await Hive.openBox(StorageKeys.habitsBox);
    _habitLogsBox = await Hive.openBox(StorageKeys.habitLogsBox);
    _settingsBox = await Hive.openBox(StorageKeys.settingsBox);
    return this;
  }

  Box<dynamic> get habitsBox => _habitsBox!;
  Box<dynamic> get habitLogsBox => _habitLogsBox!;
  Box<dynamic> get settingsBox => _settingsBox!;

  // Settings helpers
  bool get isDarkMode =>
      _settingsBox?.get(StorageKeys.isDarkMode, defaultValue: false) as bool;

  set isDarkMode(bool value) {
    _settingsBox?.put(StorageKeys.isDarkMode, value);
  }

  bool get notificationsEnabled =>
      _settingsBox?.get(StorageKeys.notificationsEnabled, defaultValue: true) as bool;

  set notificationsEnabled(bool value) {
    _settingsBox?.put(StorageKeys.notificationsEnabled, value);
  }

  /// Focus completion tone: `default`, `chime`, or `bell`.
  String get focusCompleteSound {
    final v =
        _settingsBox?.get(StorageKeys.focusCompleteSound, defaultValue: 'default')
            as String;
    if (v == 'chime' || v == 'bell') return v;
    return 'default';
  }

  set focusCompleteSound(String value) {
    final v = (value == 'chime' || value == 'bell') ? value : 'default';
    _settingsBox?.put(StorageKeys.focusCompleteSound, v);
  }

  bool get focusCompleteEnabled =>
      _settingsBox?.get(StorageKeys.focusCompleteEnabled, defaultValue: true)
          as bool;

  set focusCompleteEnabled(bool value) {
    _settingsBox?.put(StorageKeys.focusCompleteEnabled, value);
  }

  /// Full system picker: selected ringtone URI for Android.
  ///
  /// Empty string means system default.
  String get focusCompleteSoundUri =>
      _settingsBox?.get(StorageKeys.focusCompleteSoundUri,
              defaultValue: '') as String;

  set focusCompleteSoundUri(String value) {
    _settingsBox?.put(StorageKeys.focusCompleteSoundUri, value);
  }

  String get focusCompleteSoundTitle =>
      _settingsBox?.get(StorageKeys.focusCompleteSoundTitle,
          defaultValue: 'System default') as String;

  set focusCompleteSoundTitle(String value) {
    _settingsBox?.put(StorageKeys.focusCompleteSoundTitle, value);
  }
}
