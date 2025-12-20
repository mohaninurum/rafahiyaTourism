import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../view/super_admin_code/models/general_annoucement/general_annoucement_model.dart';

class UserAnnouncementProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<GeneralAnnouncement> _announcements = [];
  List<GeneralAnnouncement> get announcements => _announcements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('super_admin_general_announcements')
          .orderBy('createdAt', descending: true)
          .get();

      _announcements = snapshot.docs.map((doc) {
        final data = doc.data();
        return GeneralAnnouncement.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
