import 'package:cloud_firestore/cloud_firestore.dart';

class SliderImage {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;
  final int order;

  SliderImage({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
    required this.order,
  });

  factory SliderImage.fromMap(Map<String, dynamic> map) {
    // Handle Timestamp conversion
    DateTime uploadedAt;
    if (map['uploadedAt'] is Timestamp) {
      uploadedAt = (map['uploadedAt'] as Timestamp).toDate();
    } else if (map['uploadedAt'] is String) {
      uploadedAt = DateTime.parse(map['uploadedAt']);
    } else {
      uploadedAt = DateTime.now(); // fallback
    }

    return SliderImage(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      uploadedAt: uploadedAt,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'uploadedAt': Timestamp.fromDate(uploadedAt), // Convert to Timestamp for Firestore
      'order': order,
    };
  }
}