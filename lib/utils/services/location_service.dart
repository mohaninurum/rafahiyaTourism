// utils/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Add this enum at the top of the file
enum LocationStatus {
  available,
  serviceDisabled,
  permissionDenied,
  unableToGetLocation
}

class LocationService {
  static const String _latKey = 'user_latitude';
  static const String _lngKey = 'user_longitude';
  static const String _locationPermissionKey = 'location_permission_granted';

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_locationPermissionKey, true);
      return true;
    }
    return false;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> isLocationPermissionGranted() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // New method to check complete location status
  static Future<LocationStatus> checkLocationStatus() async {
    try {
      // First check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationStatus.serviceDisabled;
      }

      // Then check location permission
      final hasPermission = await isLocationPermissionGranted();
      if (!hasPermission) {
        return LocationStatus.permissionDenied;
      }

      // Finally, try to get actual location
      final position = await getCurrentLocation();
      if (position == null) {
        return LocationStatus.unableToGetLocation;
      }

      // Save the obtained location
      await saveUserLocation(position.latitude, position.longitude);

      return LocationStatus.available;
    } catch (e) {
      return LocationStatus.unableToGetLocation;
    }
  }

  static Future<bool> canGetLocation() async {
    final status = await checkLocationStatus();
    return status == LocationStatus.available;
  }

  // Method to open location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Method to open app settings for permission
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<void> saveUserLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lngKey, lng);
  }

  static Future<Map<String, double>?> getSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble(_latKey);
    final lng = prefs.getDouble(_lngKey);

    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }

  static Future<bool> hasLocationSaved() async {
    final location = await getSavedLocation();
    return location != null;
  }

  static Future<void> clearSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);
  }
}