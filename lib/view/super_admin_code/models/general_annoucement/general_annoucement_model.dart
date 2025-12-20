import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralAnnouncement {
  final String? id;
  final String country;
  final String city;
  final String message;
  final String uid;
  final String? fcmToken;
  final String? title;
  final DateTime? createdAt;

  GeneralAnnouncement({
    this.id,
    required this.country,
    required this.city,
    required this.message,
    required this.uid,
    required this.title,
    this.fcmToken,
    this.createdAt,
  });

  factory GeneralAnnouncement.fromMap(Map<String, dynamic> map, String id) {
    return GeneralAnnouncement(
      id: id,
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      message: map['message'] ?? '',
      title: map['title'] ?? '',
      uid: map['uid'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'city': city,
      'message': message,
      'uid': uid,
      'fcmToken': fcmToken,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}
