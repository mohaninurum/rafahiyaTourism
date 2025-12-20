import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/model/user_notifications.dart';


class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  NotificationProvider() {
    loadLocalNotifications();
  }

  // Load notifications from SharedPreferences
  Future<void> loadLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList("local_notifications") ?? [];

    _notifications = saved
        .map((s) => AppNotification.fromJson(jsonDecode(s)))
        .toList();

    notifyListeners();
  }

  // Save notifications to SharedPreferences
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = _notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList("local_notifications", saved);
  }

  // Add a new notification locally
  Future<void> addNotification(AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveLocal();
    notifyListeners();
  }

  // Mark one as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        type: _notifications[index].type,
        title: _notifications[index].title,
        message: _notifications[index].message,
        data: _notifications[index].data,
        createdAt: _notifications[index].createdAt,
        read: true,
      );
      await _saveLocal();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications
        .map((n) => AppNotification(
      id: n.id,
      type: n.type,
      title: n.title,
      message: n.message,
      data: n.data,
      createdAt: n.createdAt,
      read: true,
    ))
        .toList();

    await _saveLocal();
    notifyListeners();
  }

  // Clear old notifications
  Future<void> clearExpired() async {
    _notifications.removeWhere((n) => n.isExpired);
    await _saveLocal();
    notifyListeners();
  }
}
