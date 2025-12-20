import 'add_umrah_packages_model.dart';

class UmrahPackage {
  final String id;
  final String imagePath;
  final String title;
  final String duration;
  final String badge;
  final String nightsDetails;
  final String price;
  final String note;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<ItineraryDay> itinerary;
  final List<PackageService> services;

  UmrahPackage({
    required this.id,
    required this.imagePath,
    required this.title,
    required this.duration,
    required this.badge,
    required this.nightsDetails,
    required this.price,
    required this.note,
    this.startDate,
    this.endDate,
    this.itinerary = const [],
    this.services = const [],
  });
}