import 'package:cloud_firestore/cloud_firestore.dart';

class RequestTimingModel {
  final String id;
  final String imamName;
  final String mosqueName;
  final String message;
  final String status;
  final String title;
  final String userId;
  final DateTime timestamp;

  RequestTimingModel({
    required this.id,
    required this.imamName,
    required this.mosqueName,
    required this.message,
    required this.status,
    required this.title,
    required this.userId,
    required this.timestamp,
  });

  factory RequestTimingModel.fromMap(Map<String, dynamic> data, String docId) {
    return RequestTimingModel(
      id: docId,
      imamName: data['imamName'] ?? '',
      mosqueName: data['mosqueName'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? '',
      title: data['title'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
