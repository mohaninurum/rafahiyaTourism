// utils/services/maps_service.dart
import 'package:url_launcher/url_launcher.dart';

class MapsService {

  static Future<void> openDirections({
    required double destinationLat,
    required double destinationLng,
    double? userLat,
    double? userLng,
    String destinationName = 'Mosque',
  }) async {
    String url;

    if (userLat != null && userLng != null) {
      url = 'https://www.google.com/maps/dir/?api=1'
          '&origin=$userLat,$userLng'
          '&destination=$destinationLat,$destinationLng'
          '&destination_place_id=$destinationName'
          '&travelmode=driving';
    } else {
      // Just open the destination location
      url = 'https://www.google.com/maps/search/?api=1'
          '&query=$destinationLat,$destinationLng'
          '&query_place_id=$destinationName';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> openDirectionsWithGeo({
    required double destinationLat,
    required double destinationLng,
    double? userLat,
    double? userLng,
  }) async {
    String url;

    if (userLat != null && userLng != null) {
      url = 'geo:$userLat,$userLng?q=$destinationLat,$destinationLng(Mosque)';
    } else {
      url = 'geo:0,0?q=$destinationLat,$destinationLng(Mosque)';
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to Google Maps URL
      await openDirections(
        destinationLat: destinationLat,
        destinationLng: destinationLng,
        userLat: userLat,
        userLng: userLng,
      );
    }
  }
}