import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart'
    hide NotificationVisibility;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:habit_flow/core/services/focus_foreground_task.dart';
import 'package:habit_flow/core/services/storage_service.dart';
import 'package:habit_flow/core/theme/app_colors.dart';
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

  static const AndroidNotificationChannel _focusRunningChannel =
      AndroidNotificationChannel(
    'focus_running',
    'Focus running',
    description: 'Persistent notification while a focus session is running',
    importance: Importance.low,
  );

  static final Int64List _kFocusDoneVibration =
      Int64List.fromList(<int>[0, 380, 120, 280]);

  /// Heads-up completion — one channel per sound. [alarm] usage helps audio
  /// route to the alarm stream (more likely to be audible).
  static final List<AndroidNotificationChannel> _focusCompleteChannels =
      <AndroidNotificationChannel>[
    AndroidNotificationChannel(
      'focus_complete_v4_default',
      'Focus complete',
      description: 'Sound: system default',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _kFocusDoneVibration,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    AndroidNotificationChannel(
      'focus_complete_v4_chime',
      'Focus complete (Chime)',
      description: 'Custom chime tone',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('focus_chime'),
      enableVibration: true,
      vibrationPattern: _kFocusDoneVibration,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
    AndroidNotificationChannel(
      'focus_complete_v4_bell',
      'Focus complete (Bell)',
      description: 'Custom bell tone',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('focus_bell'),
      enableVibration: true,
      vibrationPattern: _kFocusDoneVibration,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    ),
  ];

  Future<NotificationService> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_focusChannel);
    await android?.createNotificationChannel(_focusRunningChannel);
    for (final ch in _focusCompleteChannels) {
      await android?.createNotificationChannel(ch);
    }

    await _initTimezone();
    await _requestPermissions();
    _initForegroundTask();

    return this;
  }

  static void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == 'focus_done_dismiss' && response.id != null) {
      try {
        Get.find<NotificationService>().cancelNotificationById(response.id!);
      } catch (_) {}
    }
  }

  Future<void> cancelNotificationById(int id) async {
    await _plugin.cancel(id);
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

  void _initForegroundTask() {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'focus_fgs',
        channelName: 'Focus (running)',
        channelDescription:
            'This notification appears while a focus session is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  AndroidNotificationChannel _channelForFocusCompleteSound(String soundId) {
    switch (soundId) {
      case 'chime':
        return _focusCompleteChannels[1];
      case 'bell':
        return _focusCompleteChannels[2];
      default:
        return _focusCompleteChannels[0];
    }
  }

  Future<bool> startFocusForeground({
    required String habitName,
    required DateTime endsAt,
  }) async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid) return false;

    await FlutterForegroundTask.saveData(
      key: 'focus.habitName',
      value: habitName,
    );
    await FlutterForegroundTask.saveData(
      key: 'focus.endsAtMillis',
      value: endsAt.millisecondsSinceEpoch,
    );

    if (await FlutterForegroundTask.isRunningService) return true;

    try {
      final result = await FlutterForegroundTask.startService(
        callback: focusStartCallback,
        notificationTitle: 'Focus running',
        notificationText: '$habitName • starting…',
        serviceTypes: const [ForegroundServiceTypes.dataSync],
      );
      return result is ServiceRequestSuccess;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopFocusForeground() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    if (!await FlutterForegroundTask.isRunningService) return;
    await FlutterForegroundTask.stopService();
  }

  /// Shared layout for “focus finished” (scheduled + immediate [show]).
  NotificationDetails _buildFocusCompleteNotificationDetails({
    required AndroidNotificationChannel ch,
    required String collapsedBody,
    required String bigText,
    required String iosSubtitle,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        ch.id,
        ch.name,
        channelDescription: ch.description,
        importance: Importance.max,
        priority: Priority.max,
        ticker: 'HabitFlow · Focus complete',
        playSound: true,
        enableVibration: true,
        vibrationPattern: _kFocusDoneVibration,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        color: AppColors.primary,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        styleInformation: BigTextStyleInformation(
          bigText,
          contentTitle: 'Focus complete',
          summaryText: 'HabitFlow',
        ),
        actions: const <AndroidNotificationAction>[
          AndroidNotificationAction(
            'focus_done_dismiss',
            'Dismiss',
            cancelNotification: true,
            showsUserInterface: false,
          ),
          AndroidNotificationAction(
            'focus_done_open',
            'Open app',
            cancelNotification: false,
            showsUserInterface: true,
          ),
        ],
        autoCancel: true,
        onlyAlertOnce: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        subtitle: iosSubtitle,
      ),
    );
  }

  /// Call when the session ends while the app is open — **plays sound** (the
  /// scheduled notification was cancelled, so this replaces it).
  Future<void> showFocusCompleteNow({
    required String habitId,
    required String habitName,
    required int minutesLogged,
  }) async {
    if (kIsWeb) return;
    final id = _idForFocusDone(habitId);
    final minsLabel = minutesLogged == 1 ? '1 minute' : '$minutesLogged minutes';
    final collapsedBody = '$habitName • $minsLabel logged';
    final bigText =
        '$habitName\n\nSession complete — $minsLabel logged.\nGreat job staying focused!';
    final soundId = StorageService.to.focusCompleteSound;
    final ch = _channelForFocusCompleteSound(soundId);
    final details = _buildFocusCompleteNotificationDetails(
      ch: ch,
      collapsedBody: collapsedBody,
      bigText: bigText,
      iosSubtitle: habitName,
    );
    await _plugin.show(id, 'Focus complete', collapsedBody, details);
  }

  /// Schedules a rich heads-up notification when the focus session ends.
  Future<void> scheduleFocusDone({
    required String habitId,
    required String habitName,
    required Duration after,
  }) async {
    final id = _idForFocusDone(habitId);
    final when = tz.TZDateTime.now(tz.local).add(after);
    final soundId = StorageService.to.focusCompleteSound;
    final ch = _channelForFocusCompleteSound(soundId);

    final collapsedBody = '$habitName • Time\'s up';
    final bigText =
        '$habitName\n\nTime\'s up — great job staying focused.\nTap to return to HabitFlow.';

    final details = _buildFocusCompleteNotificationDetails(
      ch: ch,
      collapsedBody: collapsedBody,
      bigText: bigText,
      iosSubtitle: habitName,
    );

    await _plugin.zonedSchedule(
      id,
      'Focus complete',
      collapsedBody,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> showFocusStarted({
    required String habitId,
    required String habitName,
    required int minutes,
  }) async {
    await _plugin.show(
      _idForFocusStarted(habitId),
      'Focus started',
      '$habitName • $minutes min',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusChannel.id,
          _focusChannel.name,
          channelDescription: _focusChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showFocusRunning({
    required String habitId,
    required String habitName,
    required DateTime endsAt,
  }) async {
    final hh = endsAt.hour.toString().padLeft(2, '0');
    final mm = endsAt.minute.toString().padLeft(2, '0');
    await _plugin.show(
      _idForFocusRunning(habitId),
      'Focus running',
      '$habitName • ends at $hh:$mm',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _focusRunningChannel.id,
          _focusRunningChannel.name,
          channelDescription: _focusRunningChannel.description,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          onlyAlertOnce: true,
          showWhen: false,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelFocusRunning(String habitId) async {
    await _plugin.cancel(_idForFocusRunning(habitId));
  }

  Future<void> cancelFocusStarted(String habitId) async {
    await _plugin.cancel(_idForFocusStarted(habitId));
  }

  Future<void> cancelFocusDone(String habitId) async {
    await _plugin.cancel(_idForFocusDone(habitId));
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  static int _idForFocusDone(String habitId) =>
      100000 + _stableHash(habitId) % 500000;

  static int _idForFocusRunning(String habitId) =>
      200000 + _stableHash('running:$habitId') % 500000;

  static int _idForFocusStarted(String habitId) =>
      300000 + _stableHash('started:$habitId') % 500000;

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
