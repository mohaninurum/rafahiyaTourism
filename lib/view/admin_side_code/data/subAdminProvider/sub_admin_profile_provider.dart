import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../const/error_handler.dart';
import '../../../super_admin_code/models/masjid_imam_adminlist.dart';

class SubAdminProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  StreamSubscription? _subscription;
  MasjidImamAdminModel? _profile;
  bool _isLoading = true;
  bool _isUploadingImage = false;

  MasjidImamAdminModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isUploadingImage => _isUploadingImage;

  getProfile(String uid) {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestore
        .collection('subAdmin')
        .doc(uid)
        .snapshots()
        .listen(
          (doc) {
        if (doc.exists) {
          _profile = MasjidImamAdminModel.fromMap(doc.data()!);
        } else {
          _profile = null;
        }
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Error: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateProfileImage(String uid, File imageFile) async {
    try {
      _isUploadingImage = true;
      notifyListeners();

      // Upload image to Firebase Storage
      final ref = _storage.ref().child('adminProfileImages').child('$uid.jpg');
      await ref.putFile(imageFile);
      final imageUrl = await ref.getDownloadURL();

      // Update Firestore with new image URL
      await _firestore.collection('subAdmin').doc(uid).update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local profile data
      if (_profile != null) {
        _profile = MasjidImamAdminModel(
          masjidPhoneNumber: _profile!.masjidPhoneNumber,
          address: _profile!.address,
          city: _profile!.city,
          createdAt: _profile!.createdAt,
          email: _profile!.email,
          imageUrl: imageUrl, // Updated image URL
          imamName: _profile!.imamName,
          latitude: _profile!.latitude,
          longitude: _profile!.longitude,
          masjidName: _profile!.masjidName,
          mobileNumber: _profile!.mobileNumber,
          pinCode: _profile!.pinCode,
          proofDocumentName: _profile!.proofDocumentName,
          proofUrl: _profile!.proofUrl,
          successfullyRegistered: _profile!.successfullyRegistered,
          uid: _profile!.uid,
          userType: _profile!.userType,
        );
      }

    } catch (e) {
      print("Error updating profile image: $e");
      rethrow;
    } finally {
      _isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("Error picking image from gallery: $e");
      rethrow;
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("Error picking image from camera: $e");
      rethrow;
    }
  }

  Future<void> updateProfileField(
      String uid,
      String fieldName,
      dynamic newValue,
      ) async {
    try {
      await _firestore.collection('subAdmin').doc(uid).update({
        fieldName: newValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ErrorHandler.showError(e);
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