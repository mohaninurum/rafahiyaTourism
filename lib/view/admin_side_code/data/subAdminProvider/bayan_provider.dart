import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/announcement_model.dart';

class BayanProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Announcement> _announcements = [];

  List<Announcement> get announcements => _announcements;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> shareBayan(
    BuildContext context,
    String title,
    String videoLink,
    File? imageFile,
  ) async {
    try {
      _setLoading(true);

      String? imageUrl;
      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child("bayan_images")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore
          .collection('mosques')
          .doc(_auth.currentUser!.uid)
          .collection('bayan')
          .add({
            "title": title,
            "videoLink": videoLink,
            "imageUrl": imageUrl,
            "createdAt": DateTime.now(),
          });

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bayan shared successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error sharing bayan: $e")));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBayanAnnouncements() async {
    try {
      _setLoading(true);

      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        _announcements = [];
        _setLoading(false);
        return;
      }

      final querySnapshot =
          await _firestore
              .collection('mosques')
              .doc(uid)
              .collection('bayan')
              .orderBy("createdAt", descending: true)
              .get();

      final colors = [Colors.blue, Colors.green, Colors.orange, Colors.red];
      int colorIndex = 0;

      _announcements =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return Announcement(
              id: doc.id,
              icon: Icons.announcement,
              iconColor: colors[colorIndex % colors.length],
              title: data['title'] ?? 'No Title',
              imageUrl: data['imageUrl'] ?? '',
              description:
                  data['videoLink']?.isNotEmpty == true
                      ? "Watch video: ${data['videoLink']}"
                      : "No video link provided",
              time:
                  (data['createdAt'] as Timestamp?)?.toDate().toString() ?? "",
            );
          }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching announcements: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBayan(
      String docId,
      String newTitle,
      String newVideoLink, {
        File? imageFile,
      }) async {
    try {
      String? imageUrl;

      // if new image selected, upload it
      if (imageFile != null) {
        final ref = _storage
            .ref()
            .child("bayan_images")
            .child("${DateTime.now().millisecondsSinceEpoch}.jpg");
        await ref.putFile(imageFile);
        imageUrl = await ref.getDownloadURL();
      }

      final updateData = {
        "title": newTitle,
        "videoLink": newVideoLink,
        "updatedAt": DateTime.now(),
      };

      if (imageUrl != null) {
        updateData["imageUrl"] = imageUrl;
      }

      await _firestore
          .collection('mosques')
          .doc(_auth.currentUser!.uid)
          .collection('bayan')
          .doc(docId)
          .update(updateData);

      await fetchBayanAnnouncements(); // refresh

      debugPrint("✅ Bayan updated successfully");
    } catch (e) {
      debugPrint("❌ Error updating bayan: $e");
    }
  }


  Future<void> deleteBayan(String docId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(_auth.currentUser!.uid)
          .collection('bayan')
          .doc(docId)
          .delete();

      _announcements.removeWhere((a) => a.id == docId);

      notifyListeners();
      debugPrint("✅ Bayan deleted successfully");
    } catch (e) {
      debugPrint("❌ Error deleting bayan: $e");
    }
  }
}
