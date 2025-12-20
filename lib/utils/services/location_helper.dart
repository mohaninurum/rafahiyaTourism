import 'package:rafahiyatourism/utils/services/location_service.dart';

class LocationHelper {

  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        await LocationService.saveUserLocation(position.latitude, position.longitude);
        return {'lat': position.latitude, 'lng': position.longitude};
      }

      return await LocationService.getSavedLocation();
    } catch (e) {
      print('Error getting location: $e');
      return await LocationService.getSavedLocation();
    }
  }

  static Future<bool> hasValidLocation() async {
    try {
      final location = await getCurrentLocation();
      return location != null;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, double>?> refreshLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      if (position != null) {
        await LocationService.saveUserLocation(position.latitude, position.longitude);
        return {'lat': position.latitude, 'lng': position.longitude};
      }
      return null;
    } catch (e) {
      print('Error refreshing location: $e');
      return null;
    }
  }
}