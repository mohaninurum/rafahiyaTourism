import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/language/app_strings.dart';

class ForgotPasswordProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(BuildContext context) async {
    final currentLocale = Localizations.localeOf(context).languageCode;

    if (!_validateEmail(currentLocale)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final email = emailController.text.trim();

      // Check if email exists in users collection first
      final userExists = await _checkIfUserExists(email);

      if (!userExists) {
        _errorMessage = AppStrings.getString('emailNotExist', currentLocale);
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);

      _successMessage = AppStrings.getString('passwordResetSent', currentLocale);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e, currentLocale);
      return false;
    } catch (e) {
      _errorMessage = AppStrings.getString('unexpectedError', currentLocale);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _checkIfUserExists(String email) async {
    try {
      // Assuming your users collection is named 'users' and has an 'email' field
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // If there's an error checking Firestore, fall back to Firebase Auth behavior
      print('Error checking user existence: $e');
      return true; // Allow the process to continue and let Firebase Auth handle it
    }
  }

  bool _validateEmail(String languageCode) {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _errorMessage = AppStrings.getString('enterEmail', languageCode);
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _errorMessage = AppStrings.getString('enterValidEmail', languageCode);
      notifyListeners();
      return false;
    }

    return true;
  }

  void _handleFirebaseError(FirebaseAuthException e, String languageCode) {
    switch (e.code) {
      case 'user-not-found':
        _errorMessage = AppStrings.getString('noUserFound', languageCode);
        break;
      case 'invalid-email':
        _errorMessage = AppStrings.getString('enterValidEmail', languageCode);
        break;
      case 'user-disabled':
        _errorMessage = AppStrings.getString('accountDisabled', languageCode);
        break;
      default:
        _errorMessage = '${AppStrings.getString('errorSendingResetEmail', languageCode)}: ${e.message}';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}