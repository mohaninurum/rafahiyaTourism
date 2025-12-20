// bayan_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Bayan {
  final String id;
  final String title;
  final String imageUrl;
  final String videoLink;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? mosqueId;
  Bayan({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.videoLink,
    required this.createdAt,
    required this.updatedAt,
    this.mosqueId,
  });

  factory Bayan.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Bayan(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoLink: data['videoLink'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      mosqueId: data['mosqueId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'videoLink': videoLink,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'mosqueId': mosqueId,
    };
  }

  Bayan copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? videoLink,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? mosqueId,
  }) {
    return Bayan(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      videoLink: videoLink ?? this.videoLink,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mosqueId: mosqueId ?? this.mosqueId,
    );
  }
}