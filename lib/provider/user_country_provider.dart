import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCountryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _userCountry;

  String? get userCountry => _userCountry;

  // Get user's country from Firestore
  Future<void> loadUserCountry() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          _userCountry = data['country'];
          print("Provider User Country $_userCountry");
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user country: $e');
      }
    }
  }

  // Set user country (for testing or manual override)
  void setUserCountry(String country) {
    _userCountry = country;
    notifyListeners();
  }
}