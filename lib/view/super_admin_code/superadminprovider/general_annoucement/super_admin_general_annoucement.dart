
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../models/general_annoucement/general_annoucement_model.dart';

class GeneralAnnouncementProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<GeneralAnnouncement> _announcements = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<GeneralAnnouncement> get announcements => _announcements;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('super_admin_general_announcements')
              .orderBy('createdAt', descending: true)
              .get();

      _announcements =
          snapshot.docs
              .map((doc) => GeneralAnnouncement.fromMap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnnouncement(GeneralAnnouncement announcement) async {
    try {
      final uid = FirebaseAuth.instance.currentUser;
      if (uid == null) {
        throw Exception("User not logged in");
      }

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        throw Exception("Unable to retrieve FCM token");
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No logged-in user found");
      }

      final Map<String, dynamic> announcementData = {
        ...announcement.toMap(),
        'createdBy': user.uid, // ✅ Attach current user ID
        'createdAt': FieldValue.serverTimestamp(), // ✅ Server time
      };

      final docRef = await _firestore
          .collection('super_admin_general_announcements')
          .add(announcement.toMap());

      _announcements.insert(
        0,
        GeneralAnnouncement(
          id: docRef.id,
          country: announcement.country,
          city: announcement.city,
          message: announcement.message,
          fcmToken: fcmToken,
          title: "New Update",
          uid: uid.uid,
          createdAt: announcement.createdAt,
        ),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding announcement: $e');
      rethrow;
    }
  }

  Future<void> updateAnnouncement(GeneralAnnouncement announcement) async {
    try {
      await _firestore
          .collection('super_admin_general_announcements')
          .doc(announcement.id)
          .update(announcement.toMap());

      final index = _announcements.indexWhere((a) => a.id == announcement.id);
      if (index != -1) {
        _announcements[index] = announcement;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating announcement: $e');
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _firestore
          .collection('super_admin_general_announcements')
          .doc(id)
          .delete();

      _announcements.removeWhere((announcement) => announcement.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting announcement: $e');
      rethrow;
    }
  }
}
