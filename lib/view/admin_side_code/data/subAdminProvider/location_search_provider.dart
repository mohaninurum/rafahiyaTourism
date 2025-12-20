import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationSearchProvider with ChangeNotifier {
  List<String> _suggestions = [];
  bool _isLoading = false;

  List<String> get suggestions => _suggestions;

  bool get isLoading => _isLoading;

  Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      _suggestions = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Flutter App', 'Accept-Language': 'en'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _suggestions =
            data.map<String>((item) => item['display_name'] as String).toList();
      } else {
        _suggestions = [];
      }
    } catch (e) {
      _suggestions = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }
}
