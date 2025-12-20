

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../admin_side_code/data/models/hadiya_model.dart';

class PendingHadiyaProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<HadiyaModel> _pendingHadiyaList = [];
  bool _isLoading = false;

  List<HadiyaModel> get pendingHadiyaList => _pendingHadiyaList;
  bool get isLoading => _isLoading;

  StreamSubscription? _subscription;

  void startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestore.collection('subAdmin').snapshots().listen((subAdminSnapshot) async {
      final hadiyaList = <HadiyaModel>[];


      for (final subAdminDoc in subAdminSnapshot.docs) {
        final subAdminId = subAdminDoc.id;
        final subAdminData = subAdminDoc.data() as Map<String, dynamic>? ?? {};

        print("subAdminId ${subAdminId}");
        print("subAdminData ${subAdminData}");

        try {
          final hadiyaSnapshot = await _firestore
              .collection('mosques')
              .doc(subAdminId)
              .collection('hadiyaDetails')
              .where('allowed', isEqualTo: false)
              .get();

          for (final hadiyaDoc in hadiyaSnapshot.docs) {
            hadiyaList.add(
                HadiyaModel.fromDocument(hadiyaDoc).withSubAdminData(subAdminData)
            );
          }
        } catch (e) {
          print('Error fetching hadiya for subadmin $subAdminId: $e');
        }
      }

      _pendingHadiyaList = hadiyaList;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateHadiyaStatus(String documentId, String mosqueId, bool isApproved) async {
    try {
      if (isApproved) {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('hadiyaDetails')
            .doc(documentId)
            .update({'allowed': true});
      } else {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('hadiyaDetails')
            .doc(documentId)
            .delete();
      }

      _pendingHadiyaList.removeWhere((hadiya) => hadiya.id == documentId);
      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update Hadiya status: $e");
    }
  }


  Future<void> deleteHadiya(String mosqueId, String hadiyaId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(mosqueId)
          .collection('hadiyaDetails')
          .doc(hadiyaId)
          .delete();

      _pendingHadiyaList.removeWhere((hadiya) => hadiya.id == hadiyaId);
      notifyListeners();

      print('Hadiya deleted successfully: $hadiyaId');
    } catch (e) {
      throw Exception("Failed to delete Hadiya: $e");
    }
  }


  Future<Map<String, dynamic>?> getMosqueDetails(String mosqueId) async {
    try {
      final doc = await _firestore.collection('subAdmin').doc(mosqueId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  void stopListening() {
    _subscription?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}