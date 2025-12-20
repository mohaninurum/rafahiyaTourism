import 'package:cloud_firestore/cloud_firestore.dart';

class HadiyaDetailModel {
  final String id;
  final String subAdminId;
  final String accountNumber;
  final String ifscCode;
  final String bankDetails;
  final String qrCodeUrl;
  final String type;
  final bool allowed;
  final DateTime createdAt;

  HadiyaDetailModel({
    required this.id,
    required this.subAdminId,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankDetails,
    required this.qrCodeUrl,
    required this.type,
    required this.allowed,
    required this.createdAt,
  });

  factory HadiyaDetailModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HadiyaDetailModel(
      id: doc.id,
      subAdminId: data['subAdminId'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      ifscCode: data['ifscCode'] ?? '',
      bankDetails: data['bankDetails'] ?? '',
      qrCodeUrl: data['qrCodeUrl'] ?? '',
      type: data['type'] ?? '',
      allowed: data['allowed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  String get status {
    if (!allowed) return 'Pending';
    return 'Approved';
  }

  bool get isApproved => allowed;
}