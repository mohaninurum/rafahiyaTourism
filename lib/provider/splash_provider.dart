import 'package:flutter/material.dart';

class SplashScreenProvider extends ChangeNotifier {
  bool animateLogo = false;
  bool animateText = false;
  bool textFinished = false;

  void startLogoAnimation() {
    animateLogo = true;
    notifyListeners();
  }

  void startTextAnimation() {
    animateText = true;
    notifyListeners();
  }

  void setFinalState() {
    textFinished = true;
    notifyListeners();
  }
}
