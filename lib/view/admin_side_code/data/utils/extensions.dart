import 'package:flutter/material.dart';
import '../../../../const/color.dart';

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    ).hasMatch(this);
  }

  String? get emailError {
    if (isEmpty) return 'Email is required';
    if (!isValidEmail()) return 'Enter a valid email address';
    return null;
  }
}

extension PasswordValidator on String {
  String? get passwordError {
    if (isEmpty) return 'Password is required';
    if (length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

extension MobileNumberValidator on String {
  bool isValidMobileNumber() {
    final cleaned = replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return false;
    }
    return RegExp(r'^[0-9]+$').hasMatch(cleaned);
  }
}


extension SnackBarExtension on BuildContext {
  void showSnackBarMessage(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.blackColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
