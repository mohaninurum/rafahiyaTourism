import 'package:cloud_firestore/cloud_firestore.dart';

class HadiyaModel {
  final String id;
  final String type;
  final String bankDetails;
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String? qrCodeUrl;
  final String? paymentLink;
  final DateTime? createdAt;
  final bool allowed;
  final String subAdminId;
  final String? masjidName;
  final String? imamName;

  HadiyaModel({
    required this.id,
    required this.type,
    required this.bankDetails,
    required this.accountHolderName, // NEW FIELD
    required this.accountNumber,
    required this.ifscCode,
    required this.allowed,
    required this.subAdminId,
    this.qrCodeUrl,
    this.paymentLink,
    this.createdAt,
    this.masjidName,
    this.imamName,
  });

  factory HadiyaModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HadiyaModel(
      id: doc.id,
      type: data['type'] ?? '',
      bankDetails: data['bankDetails'] ?? '',
      accountHolderName: data['accountHolderName'] ?? '', // NEW FIELD
      accountNumber: data['accountNumber'] ?? '',
      ifscCode: data['ifscCode'] ?? '',
      allowed: data['allowed'] ?? false,
      subAdminId: data['subAdminId'] ?? '',
      qrCodeUrl: data['qrCodeUrl'],
      paymentLink: data['paymentLink'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  HadiyaModel withSubAdminData(Map<String, dynamic> subAdminData) {
    return HadiyaModel(
      id: id,
      type: type,
      bankDetails: bankDetails,
      accountHolderName: accountHolderName, // NEW FIELD
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      allowed: allowed,
      subAdminId: subAdminId,
      qrCodeUrl: qrCodeUrl,
      paymentLink: paymentLink,
      createdAt: createdAt,
      masjidName: subAdminData['masjidName'],
      imamName: subAdminData['imamName'],
    );
  }
}