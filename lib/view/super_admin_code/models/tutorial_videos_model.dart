// tutorial_videos_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialVideo {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TutorialVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory TutorialVideo.fromMap(String id, Map<String, dynamic> map) {
    return TutorialVideo(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}