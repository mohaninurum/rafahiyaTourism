import 'package:flutter/material.dart';

class AdminOtpVerification extends ChangeNotifier {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  final String _correctOtp = "8532";

  String get enteredOtp =>
      otpControllers.map((controller) => controller.text).join();

  void clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
    notifyListeners();
  }

  void onOtpChanged(int index, String value, BuildContext context) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(focusNodes[index - 1]);
    }
    notifyListeners();
  }

  bool validateOtp() {
    return enteredOtp == _correctOtp;
  }

  @override
  void dispose() {
    otpControllers.forEach((controller) => controller.dispose());
    focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }
}
