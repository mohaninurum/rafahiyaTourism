import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/model/user_notifications.dart';

class NotificationStorage {
  static const String key = "local_notifications";

  static Future<void> saveNotification(AppNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> saved = prefs.getStringList(key) ?? [];

    saved.add(jsonEncode(notification.toJson()));

    await prefs.setStringList(key, saved);
  }

  static Future<List<AppNotification>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(key) ?? [];

    return saved
        .map((s) => AppNotification.fromJson(jsonDecode(s)))
        .toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
