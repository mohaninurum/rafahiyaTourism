import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _apiKey = 'AIzaSyD4ZqIfKBHWMLEcM8o2rdjwQzxqfA5YXDw';
  static const String _geocodingBaseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  static Future<Map<String, double>?> geocodeAddress(String address) async {
    try {
      final response = await http.get(
          Uri.parse('$_geocodingBaseUrl?address=${Uri.encodeComponent(address)}&key=$_apiKey')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'],
            'lng': location['lng'],
          };
        }
      }

      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
  }

  static Future<Map<String, double>?> geocodeAddressFree(String address) async {
    try {
      final response = await http.get(
          Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(address)}')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lng': double.parse(data[0]['lon']),
          };
        }
      }

      return null;
    } catch (e) {
      print('Free geocoding error: $e');
      return null;
    }
  }
}