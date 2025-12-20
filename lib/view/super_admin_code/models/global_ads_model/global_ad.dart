class GlobalAdModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String startDate;
  final String endDate;
  final String country;
  final String city;
  final String? link;
  bool isActive;

  GlobalAdModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.country,
    required this.city,
    this.link,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'startDate': startDate,
      'endDate': endDate,
      'country': country,
      'city': city,
      'link': link,
      'isActive': isActive,
    };
  }

  factory GlobalAdModel.fromMap(Map<String, dynamic> map) {
    return GlobalAdModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'],
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      link: map['link'],
      isActive: map['isActive'] ?? true,
    );
  }

  GlobalAdModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? startDate,
    String? endDate,
    String? country,
    String? city,
    String? link,
    bool? isActive,
  }) {
    return GlobalAdModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      country: country ?? this.country,
      city: city ?? this.city,
      link: link ?? this.link,
      isActive: isActive ?? this.isActive,
    );
  }
}