import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SuperAdminSalahProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _mosques = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<Map<String, dynamic>> get mosques => _mosques;
  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    _subscription = _firestore
        .collection('subAdmin')
        .where('successfullyRegistered', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> mosqueList = [];

      for (var doc in snapshot.docs) {
        final subAdminData = doc.data();
        final mosqueName = subAdminData['masjidName'] ?? 'Unnamed Masjid';
        final uid = subAdminData['uid'] ?? doc.id;

        try {
          // Get the corresponding mosque document from mosques collection
          final mosqueDoc = await _firestore
              .collection('mosques')
              .doc(uid)
              .get();

          if (mosqueDoc.exists) {
            mosqueList.add({
              'id': uid, // Use the UID as the mosque ID
              'name': mosqueName,
              'data': mosqueDoc.data(),
            });
          } else {
            // If mosque document doesn't exist, still add with basic info
            mosqueList.add({
              'id': uid,
              'name': mosqueName,
              'data': subAdminData,
            });
          }
        } catch (e) {
          debugPrint('Error fetching mosque data for $mosqueName: $e');
          mosqueList.add({
            'id': uid,
            'name': mosqueName,
            'data': subAdminData,
          });
        }
      }

      return mosqueList;
    }).listen((mosqueList) {
      _mosques = mosqueList;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error fetching mosques: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updatePrayerTime(String mosqueId, String prayerName, String field, String newTime) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(mosqueId)
          .collection('namazTimings')
          .doc(prayerName.toLowerCase())
          .update({
        field: newTime,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If the document doesn't exist, create it
      if (e.toString().contains('No document to update')) {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('namazTimings')
            .doc(prayerName.toLowerCase())
            .set({
          'namazName': prayerName,
          field: newTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        rethrow;
      }
    }
  }

  Future<void> updateEidPrayerTime(String mosqueId, String eidType, String jamatNumber, String newTime) async {
    try {
      final fieldName = jamatNumber.toLowerCase() == 'jamat 1' ? 'jammat1' : 'jammat2';

      await _firestore
          .collection('mosques')
          .doc(mosqueId)
          .collection('specialTimings')
          .doc(eidType.toLowerCase())
          .update({
        fieldName: newTime,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // If the document doesn't exist, create it
      if (e.toString().contains('No document to update')) {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('specialTimings')
            .doc(eidType.toLowerCase())
            .set({
          jamatNumber.toLowerCase() == 'jamat 1' ? 'jammat1' : 'jammat2': newTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        rethrow;
      }
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}