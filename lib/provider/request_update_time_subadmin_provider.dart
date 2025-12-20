
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestUpdateTimeSubAdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> sendRequest({
    required String userId,
    required String imamName,
    required String mosqueName,
    required String title,
    required String message,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('request_update_timings').add({
        'userId': userId,
        'imamName': imamName,
        'mosqueName': mosqueName,
        'title': title,
        'message': message,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Error sending request: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
