import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OfflineManager {
  static const storage = FlutterSecureStorage();
  static const String _cachedCasesKey = 'helpi_cached_cases';
  static const String _cachedNotificationsKey = 'helpi_cached_notifications';
  static const String _offlineQueueKey = 'helpi_offline_queue';

  static Future<void> cacheCases(List<dynamic> cases) async {
    try {
      await storage.write(key: _cachedCasesKey, value: jsonEncode(cases));
    } catch (_) {}
  }

  static Future<List<dynamic>> getCachedCases() async {
    try {
      final raw = await storage.read(key: _cachedCasesKey);
      if (raw != null) {
        return jsonDecode(raw) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<void> cacheNotifications(List<dynamic> notifications) async {
    try {
      await storage.write(key: _cachedNotificationsKey, value: jsonEncode(notifications));
    } catch (_) {}
  }

  static Future<List<dynamic>> getCachedNotifications() async {
    try {
      final raw = await storage.read(key: _cachedNotificationsKey);
      if (raw != null) {
        return jsonDecode(raw) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<void> enqueueOfflineAction(String endpoint, String method, Map<String, dynamic> body) async {
    try {
      final raw = await storage.read(key: _offlineQueueKey);
      List<dynamic> queue = [];
      if (raw != null) {
        queue = jsonDecode(raw) as List<dynamic>;
      }
      queue.add({
        'endpoint': endpoint,
        'method': method,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
      });
      await storage.write(key: _offlineQueueKey, value: jsonEncode(queue));
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> getOfflineQueue() async {
    try {
      final raw = await storage.read(key: _offlineQueueKey);
      if (raw != null) {
        return (jsonDecode(raw) as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> clearOfflineQueue() async {
    try {
      await storage.delete(key: _offlineQueueKey);
    } catch (_) {}
  }
}
