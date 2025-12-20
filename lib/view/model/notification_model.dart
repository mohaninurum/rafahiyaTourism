// notification_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? senderRole;
  final String? receiverRole;
  final String? receiverId;
  final Map<String, dynamic>? extraData;
  final Timestamp? timestamp;
  final Map<String, dynamic>? readBy;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.senderRole,
    this.receiverRole,
    this.receiverId,
    this.extraData,
    this.timestamp,
    this.readBy,
  });

  factory AppNotification.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      title: d['title'] ?? '',
      message: d['message'] ?? '',
      type: d['type'] ?? '',
      senderRole: d['senderRole'],
      receiverRole: d['receiverRole'],
      receiverId: d['receiverId'],
      extraData: d['extraData'] != null ? Map<String, dynamic>.from(d['extraData']) : null,
      timestamp: d['timestamp'] as Timestamp?,
      readBy: d['readBy'] != null ? Map<String, dynamic>.from(d['readBy']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'senderRole': senderRole,
      'receiverRole': receiverRole,
      'receiverId': receiverId,
      'extraData': extraData,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'readBy': readBy ?? {},
    };
  }
}


class NotificationResponse {
  final bool success;
  final int count;
  final List<NotificationItem> data;

  NotificationResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic>? json) {
    return NotificationResponse(
      success: json?['success'] ?? false,
      count: json?['count'] ?? 0,
      data: (json?['data'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e))
          .toList() ??
          [],
    );
  }
}
class NotificationItem {
  final String id;
  final String mosqueId;
  final String namazName;
  final String timeField;
  final String time;
  final String title;
  final String body;
  final String topic;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    required this.mosqueId,
    required this.namazName,
    required this.timeField,
    required this.time,
    required this.title,
    required this.body,
    required this.topic,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic>? json) {
    return NotificationItem(
      id: json?['id'] ?? '',
      mosqueId: json?['mosqueId'] ?? '',
      namazName: json?['namazName'] ?? '',
      timeField: json?['timeField'] ?? '',
      time: json?['time'] ?? '',
      title: json?['title'] ?? '',
      body: json?['body'] ?? '',
      topic: json?['topic'] ?? '',
      createdAt: FirestoreTimestamp.fromJson(json?['createdAt'])?.toDateTime(),
    );
  }
}

class FirestoreTimestamp {
  final int seconds;
  final int nanoseconds;

  FirestoreTimestamp({
    required this.seconds,
    required this.nanoseconds,
  });

  factory FirestoreTimestamp.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FirestoreTimestamp(seconds: 0, nanoseconds: 0);

    return FirestoreTimestamp(
      seconds: json['_seconds'] ?? 0,
      nanoseconds: json['_nanoseconds'] ?? 0,
    );
  }

  DateTime toDateTime() {
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
