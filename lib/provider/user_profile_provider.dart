import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rafahiyatourism/const/color.dart';

import '../utils/model/auth/auth_user_model.dart';

class UserProfileProvider with ChangeNotifier {
  AuthUserModel? _user;
  bool _isLoading = false;
  String? _error;
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  AuthUserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  File? get pickedImage => _pickedImage;

  void showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              'Choose Profile Photo',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  context,
                  icon: Icons.camera_alt,
                  text: 'Camera',
                  onTap: () => _handleImageSelection(context, ImageSource.camera),
                ),
                _buildImagePickerOption(
                  context,
                  icon: Icons.photo_library,
                  text: 'Gallery',
                  onTap: () => _handleImageSelection(context, ImageSource.gallery),
                ),
                if (_hasProfileImage)
                  _buildImagePickerOption(
                    context,
                    icon: Icons.delete,
                    text: 'Remove',
                    onTap: () => _handleRemoveImage(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasProfileImage =>
      _pickedImage != null || (_user?.profileImage?.isNotEmpty ?? false);

  Widget _buildImagePickerOption(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.mainColor),
          ),
          SizedBox(height: 8),
          Text(text, style: GoogleFonts.poppins()),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(
      BuildContext context, ImageSource source) async {
    Navigator.pop(context);
    await pickProfileImage(source);
  }

  Future<void> _handleRemoveImage(BuildContext context) async {
    Navigator.pop(context);
    await clearProfileImage();
  }

  Future<void> pickProfileImage([ImageSource source = ImageSource.gallery]) async {
    try {
      _isLoading = true;
      notifyListeners();

      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _pickedImage = File(pickedFile.path);
      }
    } catch (e) {
      _error = 'Failed to pick image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearProfileImage() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      if (_user?.profileImage?.isNotEmpty ?? false) {
        try {
          final ref = FirebaseStorage.instance.refFromURL(_user!.profileImage!);
          await ref.delete();
        } catch (e) {
          debugPrint('Error deleting old image: $e');
        }
      }
      _pickedImage = null;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'profileImage': ''});

      if (_user != null) {
        _user = _user!.copyWith(profileImage: '');
      }
    } catch (e) {
      _error = 'Failed to remove image: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadProfileImage() async {
    if (_pickedImage == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;

      // Delete old image if it exists
      if (_user?.profileImage?.isNotEmpty ?? false) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(_user!.profileImage!);
          await oldRef.delete();
        } catch (e) {
          debugPrint('Error deleting old image: $e');
        }
      }

      // Upload new image
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child('${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(_pickedImage!);
      final imageUrl = await ref.getDownloadURL();

      // Update user data locally
      if (_user != null) {
        _user = _user!.copyWith(profileImage: imageUrl);
      }

      // Clear the picked image
      _pickedImage = null;

      return imageUrl;
    } catch (e) {
      _error = 'Failed to upload image: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _error = 'No user logged in';
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (doc.exists) {
        _user = AuthUserModel.fromMap(doc.data()!, currentUser.uid);
      } else {
        _error = 'User document not found';
      }
    } catch (e) {
      _error = 'Failed to fetch profile: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(AuthUserModel updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _error = 'No user logged in';
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updatedUser.toMap());

      _user = updatedUser;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileField({
    String? fullName,
    String? pinCode,
    String? mobileNumber,
    String? city,
    String? email,
    String? profileImage,
  }) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(
      fullName: fullName,
      pinCode: pinCode,
      mobileNumber: mobileNumber,
      city: city,
      email: email,
      profileImage: profileImage,
    );

    await updateProfile(updatedUser);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _pickedImage = null;
    super.dispose();
  }
}