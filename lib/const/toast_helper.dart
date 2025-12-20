import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rafahiyatourism/const/color.dart';

class ToastHelper {
  static void show(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.mainColor,
      textColor: AppColors.blackColor,
      fontSize: 16.0,
    );
  }
}
