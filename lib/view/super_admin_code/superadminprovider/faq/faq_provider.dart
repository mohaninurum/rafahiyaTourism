import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/faq_model.dart';

class FAQProvider with ChangeNotifier {
  List<FAQ> _faqs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'faqs';

  List<FAQ> get faqs => _faqs;

  // Load FAQs from Firebase
  Future<void> loadFAQs() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      _faqs = querySnapshot.docs.map((doc) {
        return FAQ.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        });
      }).toList();

      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error loading FAQs: $error');
      }
      rethrow;
    }
  }

  // Add a new FAQ to Firebase
  Future<void> addFAQ(FAQ newFaq) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collectionName).add({
        'question': newFaq.question,
        'answer': newFaq.answer,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add the generated ID to our local list
      _faqs.add(newFaq.copyWith(id: docRef.id));
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error adding FAQ: $error');
      }
      rethrow;
    }
  }

  // Update an existing FAQ in Firebase
  Future<void> updateFAQ(String id, FAQ updatedFaq) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'question': updatedFaq.question,
        'answer': updatedFaq.answer,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _faqs.indexWhere((faq) => faq.id == id);
      if (index != -1) {
        _faqs[index] = updatedFaq;
        notifyListeners();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error updating FAQ: $error');
      }
      rethrow;
    }
  }

  // Delete an FAQ from Firebase
  Future<void> deleteFAQ(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      _faqs.removeWhere((faq) => faq.id == id);
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error deleting FAQ: $error');
      }
      rethrow;
    }
  }

  // Get FAQ by ID
  FAQ getFAQById(String id) {
    return _faqs.firstWhere((faq) => faq.id == id);
  }

  // Real-time updates listener
  void listenToFAQs() {
    _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      _faqs = snapshot.docs.map((doc) {
        return FAQ.fromMap({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        });
      }).toList();
      notifyListeners();
    });
  }
}