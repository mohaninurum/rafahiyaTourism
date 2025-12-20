
import 'package:flutter/material.dart';

import '../../models/country_cities_list.dart';


class GeneralAnnouncementFormProvider with ChangeNotifier {
  String? _selectedCountry;
  String? _selectedCity;
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  String? get selectedCountry => _selectedCountry;
  String? get selectedCity => _selectedCity;
  TextEditingController get messageController => _messageController;
  bool get isSubmitting => _isSubmitting;
  bool get isFormReady => _selectedCountry != null && _selectedCity != null;

  final Map<String, List<String>> countryCities = CitiesData.countryCities;


  void setCountry(String? country) {
    _selectedCountry = country;
    _selectedCity = null;
    notifyListeners();
  }

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }

  void setSubmitting(bool submitting) {
    _isSubmitting = submitting;
    notifyListeners();
  }

  void resetForm() {
    _selectedCountry = null;
    _selectedCity = null;
    _messageController.clear();
    _isSubmitting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}