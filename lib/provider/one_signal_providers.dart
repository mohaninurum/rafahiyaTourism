


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/model/user_notifications.dart';

class OneSignalNotificationProviders with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppNotification> _allNotifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _allNotifications
      .where((notification) => !notification.isExpired)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final userRole = await _getUserRole();
      List<AppNotification> allNotifications = [];

      if (userRole == 'superAdmin') {
        allNotifications = await _fetchSuperAdminNotifications();
      } else if (userRole == 'subAdmin') {
        allNotifications = await _fetchSubAdminNotifications(user.uid);
      } else {
        allNotifications = await _fetchUserNotifications();
      }

      _allNotifications = allNotifications;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch notifications: $e';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AppNotification>> _fetchSuperAdminNotifications() async {
    List<AppNotification> notifications = [];

    // Get announcements
    final announcements = await _firestore
        .collection('super_admin_general_announcements')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in announcements.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'super_admin_general_announcements',
        title: data['title'] ?? 'Announcement',
        message: data['message'] ?? '',
        data: {'announcementId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    // Get update requests
    final updateRequests = await _firestore
        .collection('request_update_timings')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in updateRequests.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'request_update_timings',
        title: data['title'] ?? 'Update Request',
        message: data['message'] ?? 'Timing update requested',
        data: {'requestId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    return notifications;
  }

  Future<List<AppNotification>> _fetchSubAdminNotifications(String userId) async {
    List<AppNotification> notifications = [];

    // Get announcements
    final announcements = await _firestore
        .collection('super_admin_general_announcements')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in announcements.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'super_admin_general_announcements',
        title: data['title'] ?? 'Announcement',
        message: data['message'] ?? '',
        data: {'announcementId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    // Get user's update requests
    final updateRequests = await _firestore
        .collection('request_update_timings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in updateRequests.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'request_update_timings',
        title: data['title'] ?? 'Update Request',
        message: data['message'] ?? 'Timing update requested',
        data: {'requestId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    return notifications;
  }

  Future<List<AppNotification>> _fetchUserNotifications() async {
    List<AppNotification> notifications = [];

    // Get announcements
    final announcements = await _firestore
        .collection('super_admin_general_announcements')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in announcements.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'super_admin_general_announcements',
        title: data['title'] ?? 'Announcement',
        message: data['message'] ?? '',
        data: {'announcementId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    // Get community services
    final communityServices = await _firestore
        .collection('community_services')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in communityServices.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'community_service',
        title: data['title'] ?? 'Community Service',
        message: data['description'] ?? 'New community service available',
        data: {'communityServiceId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    // Get packages
    final packages = await _firestore
        .collection('packages')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in packages.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'package_announcement',
        title: data['title'] ?? 'New Package',
        message: 'New Umrah package available',
        data: {'packageId': doc.id},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    // Get tutorial videos
    final tutorialVideos = await _firestore
        .collection('tutorial_videos')
        .orderBy('createdAt', descending: true)
        .get();

    for (var doc in tutorialVideos.docs) {
      final data = doc.data();
      notifications.add(AppNotification(
        id: doc.id,
        type: 'tutorial_video',
        title: data['title'] ?? 'Tutorial Video',
        message: data['description'] ?? 'New tutorial video available',
        data: {'videoId': doc.id, 'videoUrl': data['videoUrl']},
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        read: false,
      ));
    }

    return notifications;
  }

  Future<String> _getUserRole() async {
    final user = _auth.currentUser!;

    final superAdminDoc = await _firestore.collection('super_admins').doc(user.uid).get();
    if (superAdminDoc.exists) return 'superAdmin';

    final subAdminDoc = await _firestore.collection('subAdmin').doc(user.uid).get();
    if (subAdminDoc.exists) return 'subAdmin';

    return 'user';
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _allNotifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final oldNotification = _allNotifications[index];
        _allNotifications[index] = AppNotification(
          id: oldNotification.id,
          type: oldNotification.type,
          title: oldNotification.title,
          message: oldNotification.message,
          data: oldNotification.data,
          createdAt: oldNotification.createdAt,
          read: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (int i = 0; i < _allNotifications.length; i++) {
        if (!_allNotifications[i].read) {
          final oldNotification = _allNotifications[i];
          _allNotifications[i] = AppNotification(
            id: oldNotification.id,
            type: oldNotification.type,
            title: oldNotification.title,
            message: oldNotification.message,
            data: oldNotification.data,
            createdAt: oldNotification.createdAt,
            read: true,
          );
        }
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all as read: $e';
    }
  }

  int get unreadCount {
    return _allNotifications
        .where((notification) => !notification.read && !notification.isExpired)
        .length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add this method to create test data
  Future<void> addTestData() async {
    // Add test announcement
    await _firestore.collection('super_admin_general_announcements').add({
      'title': 'Welcome to Rafahiya Tourism',
      'message': 'Thank you for using our app. Explore all features!',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add test community service
    await _firestore.collection('community_services').add({
      'title': 'Community Cleanup Event',
      'description': 'Join us for a community cleanup this weekend',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add test package
    await _firestore.collection('packages').add({
      'title': 'Special Umrah Package',
      'price': '999',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Add test tutorial video
    await _firestore.collection('tutorial_videos').add({
      'title': 'How to Use Prayer Times',
      'description': 'Learn how to use the prayer times feature',
      'videoUrl': 'https://example.com/video1',
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('✅ Test data added successfully');
  }
}