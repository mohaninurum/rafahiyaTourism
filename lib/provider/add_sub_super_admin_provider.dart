import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSubSuperAdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  String? get nameError => _nameError;
  String? get emailError => _emailError;
  String? get phoneError => _phoneError;
  String? get passwordError => _passwordError;

  void _clearErrors() {
    _nameError = _emailError = _phoneError = _passwordError = null;
    notifyListeners();
  }

  Future<bool> _isEmailUnique(String email) async {
    final query = await _firestore
        .collection('super_admins')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<bool> _isPhoneUnique(String phone) async {
    final query = await _firestore
        .collection('super_admins')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  Future<bool> validateName(String? value) async {
    if (value == null || value.isEmpty) {
      _nameError = 'Please enter name';
      notifyListeners();
      return false;
    }
    _nameError = null;
    notifyListeners();
    return true;
  }

  Future<bool> validateEmail(String? value) async {
    if (value == null || value.isEmpty) {
      _emailError = 'Please enter email';
      notifyListeners();
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      _emailError = 'Please enter a valid email';
      notifyListeners();
      return false;
    }
    if (!await _isEmailUnique(value)) {
      _emailError = 'Email already exists';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }

  Future<bool> validatePhone(String? value) async {
    if (value == null || value.isEmpty) {
      _phoneError = 'Please enter phone number';
      notifyListeners();
      return false;
    }
    if (!await _isPhoneUnique(value)) {
      _phoneError = 'Phone number already exists';
      notifyListeners();
      return false;
    }
    _phoneError = null;
    notifyListeners();
    return true;
  }

  Future<bool> validatePassword(String? value) async {
    if (value == null || value.isEmpty) {
      _passwordError = 'Please enter password';
      notifyListeners();
      return false;
    }
    if (value.length < 8) {
      _passwordError = 'Password must be at least 8 characters';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }

  Future<bool> createSuperAdmin({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _clearErrors();
    _isLoading = true;
    notifyListeners();

    try {
      // Validate all fields
      final isNameValid = await validateName(name);
      final isEmailValid = await validateEmail(email);
      final isPhoneValid = await validatePhone(phone);
      final isPasswordValid = await validatePassword(password);

      if (!isNameValid || !isEmailValid || !isPhoneValid || !isPasswordValid) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional data in Firestore
      await _firestore.collection('super_admins').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'super_admin',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });

      return true;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _passwordError = 'The password provided is too weak';
      } else if (e.code == 'email-already-in-use') {
        _emailError = 'The account already exists for that email';
      } else {
        _emailError = 'Authentication error: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _emailError = 'Error creating super admin: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}