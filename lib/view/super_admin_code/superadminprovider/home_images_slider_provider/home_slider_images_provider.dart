
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/slider_image_model.dart';

class SliderImagesProvider with ChangeNotifier {
  List<SliderImage> _sliderImages = [];
  bool _hasError = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<SliderImage> get sliderImages => _sliderImages;
  bool get hasError => _hasError;


  Future<void> loadSliderImages() async {
    try {
      _hasError = false;
      final QuerySnapshot snapshot = await _firestore
          .collection('slider_images')
          .orderBy('order') // Add orderBy to ensure consistent ordering
          .get();

      _sliderImages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Handle Timestamp conversion properly
        DateTime uploadedAt;
        if (data['uploadedAt'] is Timestamp) {
          uploadedAt = (data['uploadedAt'] as Timestamp).toDate();
        } else {
          uploadedAt = DateTime.now();
        }

        return SliderImage.fromMap({
          'id': doc.id,
          'imageUrl': data['imageUrl'],
          'uploadedAt': uploadedAt,
          'order': data['order'] ?? 0,
        });
      }).toList();

      notifyListeners();
    } catch (error) {
      _hasError = true;
      if (kDebugMode) {
        print('Error loading slider images: $error');
      }

      // Fallback to local assets
      _sliderImages = [
        SliderImage(
          id: '1',
          imageUrl: 'assets/images/slider_1.jpg',
          uploadedAt: DateTime.now(),
          order: 0,
        ),
        SliderImage(
          id: '2',
          imageUrl: 'assets/images/slider_2.jpg',
          uploadedAt: DateTime.now(),
          order: 1,
        ),
        SliderImage(
          id: '3',
          imageUrl: 'assets/images/slider_3.jpg',
          uploadedAt: DateTime.now(),
          order: 2,
        ),
      ];
      notifyListeners();
    }
  }

  Future<void> addSliderImage(File imageFile) async {
    try {
      final String fileName = 'slider_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final Reference storageRef = _storage.ref().child('slider_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      final String downloadUrl = await snapshot.ref.getDownloadURL();

      final DocumentReference docRef = await _firestore.collection('slider_images').add({
        'imageUrl': downloadUrl,
        'uploadedAt': Timestamp.fromDate(DateTime.now()),
        'order': _sliderImages.length,
      });

      final newImage = SliderImage(
        id: docRef.id,
        imageUrl: downloadUrl,
        uploadedAt: DateTime.now(),
        order: _sliderImages.length,
      );

      _sliderImages.add(newImage);
      notifyListeners(); // This should trigger UI update

    } catch (error) {
      if (kDebugMode) {
        print('Error uploading image: $error');
      }
      rethrow;
    }
  }

  Future<void> deleteSliderImage(String id, String imageUrl) async {
    try {
      await _firestore.collection('slider_images').doc(id).delete();

      if (imageUrl.contains('firebasestorage.googleapis.com')) {
        final Reference storageRef = _storage.refFromURL(imageUrl);
        await storageRef.delete();
      }

      _sliderImages.removeWhere((image) => image.id == id);

      for (int i = 0; i < _sliderImages.length; i++) {
        await _firestore.collection('slider_images').doc(_sliderImages[i].id).update({
          'order': i,
        });
        _sliderImages[i] = SliderImage(
          id: _sliderImages[i].id,
          imageUrl: _sliderImages[i].imageUrl,
          uploadedAt: _sliderImages[i].uploadedAt,
          order: i,
        );
      }

      notifyListeners();

    } catch (error) {
      if (kDebugMode) {
        print('Error deleting image: $error');
      }
      // Re-throw the error so it can be handled in the UI
      rethrow;
    }
  }

  Future<void> reorderImages(int oldIndex, int newIndex) async {
    try {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final SliderImage item = _sliderImages.removeAt(oldIndex);
      _sliderImages.insert(newIndex, item);
      final batch = _firestore.batch();

      for (int i = 0; i < _sliderImages.length; i++) {
        final docRef = _firestore.collection('slider_images').doc(_sliderImages[i].id);
        batch.update(docRef, {'order': i});

        _sliderImages[i] = SliderImage(
          id: _sliderImages[i].id,
          imageUrl: _sliderImages[i].imageUrl,
          uploadedAt: _sliderImages[i].uploadedAt,
          order: i,
        );
      }

      await batch.commit();
      notifyListeners();

    } catch (error) {
      if (kDebugMode) {
        print('Error reordering images: $error');
      }
      rethrow;
    }
  }
}