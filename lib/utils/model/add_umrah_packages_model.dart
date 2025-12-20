class AddUmrahPackage {
  final String id;
  final String title;
  final String price;
  final DateTime? startDate;
  final DateTime? endDate;
  final String note;
  final String imageUrl; // Changed from imagePath to imageUrl
  final List<ItineraryDay> itinerary;
  final List<PackageService> services;

  AddUmrahPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.note,
    required this.imageUrl, // Changed parameter name
    required this.itinerary,
    this.services = const [],
  });

  AddUmrahPackage copyWith({
    String? id,
    String? title,
    String? price,
    DateTime? startDate,
    DateTime? endDate,
    String? note,
    String? imageUrl, // Changed parameter name
    List<ItineraryDay>? itinerary,
    List<PackageService>? services,
  }) {
    return AddUmrahPackage(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      note: note ?? this.note,
      imageUrl: imageUrl ?? this.imageUrl, // Changed parameter name
      itinerary: itinerary ?? this.itinerary,
      services: services ?? this.services,
    );
  }

  int get durationInDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  String get durationString {
    return '$durationInDays ${durationInDays == 1 ? 'Day' : 'Days'}';
  }
}

class ItineraryDay {
  final DateTime date;
  final String activities;

  ItineraryDay({
    required this.date,
    required this.activities,
  });
}

class PackageService {
  final String name;
  final String description;

  PackageService({
    required this.name,
    required this.description,
  });
}