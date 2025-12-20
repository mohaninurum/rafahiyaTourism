import 'package:cloud_firestore/cloud_firestore.dart';

class MasjidImamAdminModel {
  final String address;
  final String city;
  final DateTime createdAt;
  final String email;
  final String imamName;
  final double latitude;
  final double longitude;
  final String masjidName;
  final String mobileNumber;
  final String masjidPhoneNumber;
  final String pinCode;
  final String imageUrl;
  final String proofDocumentName;
  final String proofUrl;
  final bool successfullyRegistered;
  final String uid;
  final String userType;

  MasjidImamAdminModel({
    required this.masjidPhoneNumber,
    required this.address,
    required this.city,
    required this.createdAt,
    required this.email,
    required this.imageUrl,
    required this.imamName,
    required this.latitude,
    required this.longitude,
    required this.masjidName,
    required this.mobileNumber,
    required this.pinCode,
    required this.proofDocumentName,
    required this.proofUrl, // Add this parameter
    required this.successfullyRegistered,
    required this.uid,
    required this.userType,
  });

  factory MasjidImamAdminModel.fromMap(Map<String, dynamic> data) {
    final location = data['location'] ?? {};
    return MasjidImamAdminModel(
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      city: data['city'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      email: data['email'] ?? '',
      imamName: data['imamName'] ?? '',
      latitude: location['latitude']?.toDouble() ?? 0.0,
      longitude: location['longitude']?.toDouble() ?? 0.0,
      masjidName: data['masjidName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      masjidPhoneNumber: data['masjidPhoneNumber'] ?? '',
      pinCode: data['pinCode'] ?? '',
      proofDocumentName: data['proofDocumentName'] ?? '',
      proofUrl: data['proofUrl'] ?? '', // Add this line
      successfullyRegistered: data['successfullyRegistered'] ?? false,
      uid: data['uid'] ?? '',
      userType: data['userType'] ?? '',
    );
  }
}