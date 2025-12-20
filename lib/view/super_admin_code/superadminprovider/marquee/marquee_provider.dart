import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarqueeProvider with ChangeNotifier {
  String _marqueeText = 'Salah clock data is provided by masjid Admin';
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;

  String get marqueeText => _marqueeText;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  MarqueeProvider() {
    _initializeMarqueeText();
  }

  Future<void> _initializeMarqueeText() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('marqueeText')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('text')) {
          _marqueeText = data['text'] ?? _marqueeText;
        }
      } else {
        // Create the document if it doesn't exist
        await _createInitialDocument();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing marquee text: $e');
      }
      _error = 'Failed to load marquee text: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Set up real-time listener
    _setupRealTimeListener();
  }

  Future<void> _createInitialDocument() async {
    try {
      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('marqueeText')
          .set({
        'text': _marqueeText,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating initial document: $e');
      }
    }
  }

  void _setupRealTimeListener() {
    FirebaseFirestore.instance
        .collection('app_settings')
        .doc('marqueeText')
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('text')) {
          final newText = data['text'] ?? _marqueeText;
          if (newText != _marqueeText) {
            _marqueeText = newText;
            notifyListeners();
          }
        }
      }
    }, onError: (error) {
      if (kDebugMode) {
        print('Real-time marquee error: $error');
      }
      _error = 'Real-time update error: ${error.toString()}';
      notifyListeners();
    });
  }

  Future<bool> updateMarqueeText(String newText) async {
    try {
      _isSaving = true;
      _error = null;
      notifyListeners();

      // Validate input
      if (newText.trim().isEmpty) {
        _error = 'Marquee text cannot be empty';
        return false;
      }

      if (newText.trim().length < 5) {
        _error = 'Text should be at least 5 characters long';
        return false;
      }

      await FirebaseFirestore.instance
          .collection('app_settings')
          .doc('marqueeText')
          .set({
        'text': newText.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to preserve other fields

      _marqueeText = newText.trim();

      if (kDebugMode) {
        print('Marquee text updated successfully: $_marqueeText');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating marquee text: $e');
      }
      _error = 'Failed to update marquee text: ${e.toString()}';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}