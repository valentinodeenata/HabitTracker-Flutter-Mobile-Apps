abstract class StorageKeys {
  static const String habitsBox = 'habits';
  static const String habitLogsBox = 'habit_logs';
  static const String settingsBox = 'settings';

  static const String habits = 'habits_list';
  static const String habitLogs = 'habit_logs_list';
  static const String isDarkMode = 'is_dark_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  /// `default` | `chime` | `bell` — Android raw resources + channel mapping.
  static const String focusCompleteSound = 'focus_complete_sound';

  /// When false, system notification sound/alert for focus completion is disabled.
  static const String focusCompleteEnabled = 'focus_complete_enabled';

  /// Selected system sound URI (Android). Empty string means system default.
  static const String focusCompleteSoundUri = 'focus_complete_sound_uri';

  /// Cached display title for the selected URI (purely for UI).
  static const String focusCompleteSoundTitle =
      'focus_complete_sound_title';
}
