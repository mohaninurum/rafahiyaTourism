
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rafahiyatourism/utils/services/location_service.dart';

class NearbyMosqueProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _nearbyMosques = [];
  bool _isLoading = false;
  String? _error;
  double _searchRadius = 5.0;
  Position? _userPosition;
  String? _customLocationName;
  String? get customLocationName => _customLocationName;

  List<Map<String, dynamic>> get nearbyMosques => _nearbyMosques;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get searchRadius => _searchRadius;
  Position? get userPosition => _userPosition;

  void setSearchRadius(double radius) {
    _searchRadius = radius;
    notifyListeners();
  }

  Future<void> fetchNearbyMosques() async {
    _isLoading = true;
    _error = null;
    _customLocationName = null;
    notifyListeners();

    try {
      // Get user's current location
      _userPosition = await _getUserLocation();

      if (_userPosition == null) {
        _error = 'Unable to get your current location';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch all mosques from Firestore
      final mosquesSnapshot = await _firestore
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      _nearbyMosques = _filterMosquesByDistance(
          mosquesSnapshot.docs,
          _userPosition!,
          _searchRadius
      );

      // Sort by distance
      _nearbyMosques.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    } catch (e) {
      _error = 'Error fetching nearby mosques: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMosquesByCoordinates(double lat, double lng, String locationName) async {
    _isLoading = true;
    _error = null;
    _customLocationName = locationName;
    notifyListeners();

    try {
      // Create a mock position for the custom location
      _userPosition = Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      // Fetch all mosques from Firestore
      final mosquesSnapshot = await _firestore
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      _nearbyMosques = _filterMosquesByDistance(
          mosquesSnapshot.docs,
          _userPosition!,
          _searchRadius
      );

      // Sort by distance
      _nearbyMosques.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

    } catch (e) {
      _error = 'Error fetching mosques: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<Position?> _getUserLocation() async {
    try {
      // Try to get current location first
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      if (position != null) {
        // Save the location for future use
        await LocationService.saveUserLocation(position.latitude, position.longitude);
        return position;
      }

      // Fallback to saved location
      final savedLocation = await LocationService.getSavedLocation();
      if (savedLocation != null) {
        return Position(
          latitude: savedLocation['lat']!,
          longitude: savedLocation['lng']!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0, // ✅ Added
          headingAccuracy: 0,  // ✅ Added
        );

      }

      return null;
    } catch (e) {
      // Fallback to saved location
      final savedLocation = await LocationService.getSavedLocation();
      if (savedLocation != null) {
        return Position(
          latitude: savedLocation['lat']!,
          longitude: savedLocation['lng']!,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0, // ✅ Added
          headingAccuracy: 0,  // ✅ Added
        );

      }
      return null;
    }
  }

  List<Map<String, dynamic>> _filterMosquesByDistance(
      List<QueryDocumentSnapshot> mosques,
      Position userPosition,
      double radiusKm) {

    final List<Map<String, dynamic>> nearby = [];

    for (var mosqueDoc in mosques) {
      final mosqueData = mosqueDoc.data() as Map<String, dynamic>;
      final location = mosqueData['location'];

      if (location != null && location['latitude'] != null && location['longitude'] != null) {
        final double mosqueLat = location['latitude'] is double
            ? location['latitude']
            : double.tryParse(location['latitude'].toString()) ?? 0.0;

        final double mosqueLng = location['longitude'] is double
            ? location['longitude']
            : double.tryParse(location['longitude'].toString()) ?? 0.0;

        if (mosqueLat != 0.0 && mosqueLng != 0.0) {
          final distance = _calculateDistance(
            userPosition.latitude,
            userPosition.longitude,
            mosqueLat,
            mosqueLng,
          );

          if (distance <= radiusKm) {
            nearby.add({
              ...mosqueData,
              'uid': mosqueDoc.id,
              'distance': distance,
              'distanceText': '${distance.toStringAsFixed(1)} km',
            });
          }
        }
      }
    }

    return nearby;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

  void clearNearbyMosques() {
    _nearbyMosques.clear();
    notifyListeners();
  }
}