import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../utils/language/app_strings.dart';

class SubAdminForgotPasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  String? validateEmail(String email, {String languageCode = 'en'}) {
    if (email.isEmpty) {
      return AppStrings.getString('emailRequired', languageCode);
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return AppStrings.getString('enterValidEmail', languageCode);
    }
    return null;
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    final currentLocale = Localizations.localeOf(context).languageCode;

    _errorMessage = null;
    _successMessage = null;

    final emailError = validateEmail(email, languageCode: currentLocale);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final emailExists = await _checkIfEmailExists(email.trim().toLowerCase());

      if (!emailExists) {
        _isLoading = false;
        _errorMessage = AppStrings.getString('emailNotExist', currentLocale);
        notifyListeners();
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _successMessage = AppStrings.getString('resetLinkSent', currentLocale);
      _isLoading = false;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
          _successMessage = null;
        }
      });

    } on FirebaseAuthException catch (e) {
      _isLoading = false;

      switch (e.code) {
        case 'user-not-found':
          _errorMessage = AppStrings.getString('emailNotExist', currentLocale);
          break;
        case 'invalid-email':
          _errorMessage = AppStrings.getString('enterValidEmail', currentLocale);
          break;
        case 'user-disabled':
          _errorMessage = AppStrings.getString('accountDisabled', currentLocale);
          break;
        default:
          _errorMessage = AppStrings.getString('errorOccurred', currentLocale);
      }

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = AppStrings.getString('unexpectedError', currentLocale);
      notifyListeners();
    }
  }

  Future<bool> _checkIfEmailExists(String email) async {
    try {
      final firestore = FirebaseFirestore.instance;

      final subAdminQuery = await firestore
          .collection('subAdmin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (subAdminQuery.docs.isNotEmpty) {
        return true;
      }

      final superAdminQuery = await firestore
          .collection('super_admins')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return superAdminQuery.docs.isNotEmpty;

    } catch (e) {
      print('Error checking email existence: $e');
      return true;
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}