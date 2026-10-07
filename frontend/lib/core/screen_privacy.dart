import 'package:flutter/services.dart';

class ScreenPrivacy {
  static const MethodChannel _channel = MethodChannel('helpi/screen_privacy');

  static Future<void> enableSecureFlag() async {
    try {
      await _channel.invokeMethod('enableSecure');
    } catch (_) {
      // Graceful fallback if platform channel isn't registered
    }
  }

  static Future<void> disableSecureFlag() async {
    try {
      await _channel.invokeMethod('disableSecure');
    } catch (_) {}
  }
}
