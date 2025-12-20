import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ErrorHandler {
  static showError(dynamic error) {
    final message = _getErrorMessage(error);

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static String _getErrorMessage(dynamic error) {
    if (error is FirebaseException) {
      return error.message ?? "A Firebase error occurred.";
    } else if (error is PlatformException) {
      return error.message ?? "A platform error occurred.";
    } else {
      return "Something went wrong. Please try again.";
    }
  }
}
