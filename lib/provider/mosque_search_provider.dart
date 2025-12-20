import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MosqueSearchProvider with ChangeNotifier {
  List<Map<String, dynamic>> _mosques = [];
  List<Map<String, dynamic>> _filteredMosques = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get mosques => _mosques;
  List<Map<String, dynamic>> get filteredMosques => _filteredMosques;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadMosques() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      _mosques = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'name': data['masjidName'] ?? '',
          'address': data['address'] ?? '',
          'location': data['location'] ?? {},
        };
      }).toList();

      // Initially show empty filtered list
      _filteredMosques = [];
    } catch (e) {
      if (kDebugMode) {
        print('Error loading mosques: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterMosques(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredMosques = [];
    } else {
      _filteredMosques = _mosques
          .where((mosque) => mosque['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredMosques = [];
    notifyListeners();
  }
}