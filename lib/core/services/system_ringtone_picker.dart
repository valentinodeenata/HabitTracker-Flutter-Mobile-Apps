import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PickedSystemSound {
  final String uri;
  final String title;

  const PickedSystemSound({
    required this.uri,
    required this.title,
  });
}

/// Android-only: opens the system ringtone/alarm picker and returns the
/// selected sound as a content URI string.
class SystemRingtonePicker {
  SystemRingtonePicker._();

  static const MethodChannel _channel =
      MethodChannel('habitflow/system_ringtone_picker');

  static Future<PickedSystemSound?> pickAlarmSound() async {
    if (kIsWeb) return null;
    if (!Platform.isAndroid) return null;

    final result = await _channel.invokeMethod<dynamic>('pickAlarmSound');

    if (result is Map) {
      final uri = (result['uri'] as String?) ?? '';
      final title = (result['title'] as String?) ?? 'System default';
      return PickedSystemSound(uri: uri, title: title);
    }

    return null;
  }
}

