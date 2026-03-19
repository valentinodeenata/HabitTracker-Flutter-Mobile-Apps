import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService extends GetxService {
  static NotificationService get to => Get.find<NotificationService>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _focusChannel =
      AndroidNotificationChannel(
    'focus',
    'Focus sessions',
    description: 'Notifications for focus session timers',
    importance: Importance.max,
  );

  Future<NotificationService> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Create channels on Android
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_focusChannel);

    await _initTimezone();
    await _requestPermissions();

    return this;
  }

  Future<void> _initTimezone() async {
    tz.initializeTimeZones();
    try {
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    if (Platform.isAndroid) {
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } else if (Platform.isIOS || Platform.isMacOS) {
      final ios =
          _plugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Schedules a local notification when focus session ends.
  Future<void> scheduleFocusDone({
    required String habitId,
    required String habitName,
    required Duration after,
  }) async {
    final id = _idForFocusDone(habitId);
    final when = tz.TZDateTime.now(tz.local).add(after);

    await _plugin.zonedSchedule(
      id,
      'Focus complete',
      habitName,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusChannel.id,
          _focusChannel.name,
          channelDescription: _focusChannel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      // Use inexact mode to avoid heavier/strict exact alarm behavior
      // that can stall UI on some devices.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelFocusDone(String habitId) async {
    await _plugin.cancel(_idForFocusDone(habitId));
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  static int _idForFocusDone(String habitId) =>
      100000 + _stableHash(habitId) % 500000;

  static int _stableHash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = 0x1fffffff & (h + c);
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h.abs();
  }
}

