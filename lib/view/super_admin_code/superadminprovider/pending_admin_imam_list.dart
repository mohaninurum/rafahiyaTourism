


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/request_timing_model.dart';
import '../models/masjid_imam_adminlist.dart';

class PendingAdminImamListProvider with ChangeNotifier {

  List<RequestTimingModel> _requests = [];
  List<RequestTimingModel> get requests => _requests;

  bool isLoadingRequests = false;
  String? requestError;


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MasjidImamAdminModel> _unregisteredUsers = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<MasjidImamAdminModel> get unregisteredUsers => _unregisteredUsers;

  bool get isLoading => _isLoading;

  void startListening() {
    _isLoading = true;

    _subscription = _firestore
        .collection('subAdmin')
        .where('successfullyRegistered', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      final newList = snapshot.docs
          .map((doc) => MasjidImamAdminModel.fromMap(doc.data()))
          .toList();

      if (!_areListsEqual(_unregisteredUsers, newList)) {
        _unregisteredUsers = newList;
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print('Error fetching users: $error');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchRequestUpdateTimings() async {
    try {
      isLoadingRequests = true;
      requestError = null;
      notifyListeners();

      final snapshot = await FirebaseFirestore.instance
          .collection('request_update_timings')
          .get();

      _requests = snapshot.docs
          .map((doc) => RequestTimingModel.fromMap(doc.data(), doc.id))
          .toList();

    } catch (e) {
      requestError = e.toString();
    } finally {
      isLoadingRequests = false;
      notifyListeners();
    }
  }


  Future<void> updateRegistrationStatus(String userId, bool isApproved) async {
    if (!isApproved) return; // Don't update if rejected

    try {
      await _firestore.collection('subAdmin').doc(userId).update({
        'successfullyRegistered': true,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating registration status: $e");
    }
  }

  bool _areListsEqual(List<MasjidImamAdminModel> a,
      List<MasjidImamAdminModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].email != b[i].email) return false;
    }
    return true;
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
