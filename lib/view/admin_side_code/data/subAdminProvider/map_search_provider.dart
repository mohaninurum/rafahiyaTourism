import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSearchProvider with ChangeNotifier {
  LatLng? _selectedLatLng;
  String _selectedAddress = '';

  LatLng? get selectedLatLng => _selectedLatLng;

  String get selectedAddress => _selectedAddress;

  void updateLocation(LatLng position, String address) {
    _selectedLatLng = position;
    _selectedAddress = address;
    notifyListeners();
  }

  void clearSelection() {
    _selectedLatLng = null;
    _selectedAddress = '';
    notifyListeners();
  }
}
