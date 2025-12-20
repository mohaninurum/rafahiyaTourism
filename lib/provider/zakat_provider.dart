import 'package:flutter/material.dart';
class ZakatProvider extends ChangeNotifier {
  double _cashSavings = 0;
  double _goldValue = 0;
  double _silverValue = 0;
  double _investments = 0;
  double _businessAssets = 0;
  double _otherAssets = 0;
  double _liabilities = 0;
  bool _useGoldStandard = true;

  // Getters
  double get cashSavings => _cashSavings;
  double get goldValue => _goldValue;
  double get silverValue => _silverValue;
  double get investments => _investments;
  double get businessAssets => _businessAssets;
  double get otherAssets => _otherAssets;
  double get liabilities => _liabilities;
  bool get useGoldStandard => _useGoldStandard;

  // Setters
  void updateCashSavings(double value) {
    _cashSavings = value;
    notifyListeners();
  }

  void updateGoldValue(double value) {
    _goldValue = value;
    notifyListeners();
  }

  void updateSilverValue(double value) {
    _silverValue = value;
    notifyListeners();
  }

  void updateInvestments(double value) {
    _investments = value;
    notifyListeners();
  }

  void updateBusinessAssets(double value) {
    _businessAssets = value;
    notifyListeners();
  }

  void updateOtherAssets(double value) {
    _otherAssets = value;
    notifyListeners();
  }

  void updateLiabilities(double value) {
    _liabilities = value;
    notifyListeners();
  }

  void toggleNisabStandard() {
    _useGoldStandard = !_useGoldStandard;
    notifyListeners();
  }

  // Calculations
  double get totalAssets => _cashSavings + _goldValue + _silverValue + _investments + _businessAssets + _otherAssets;
  double get netWorth => totalAssets - _liabilities;

  int get nisabThreshold {
    const goldPricePerGram = 70; // Example: $70 per gram
    const silverPricePerGram = 1; // Example: $1 per gram
    return _useGoldStandard ? 85 * goldPricePerGram : 595 * silverPricePerGram;
  }

  bool get isNisabReached => netWorth >= nisabThreshold;
  double get zakatAmount => isNisabReached ? netWorth * 0.025 : 0;
}