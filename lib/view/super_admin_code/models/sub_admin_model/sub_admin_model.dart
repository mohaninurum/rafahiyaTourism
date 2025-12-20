import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String masjidName;
  final String pincode;
  final String address;
  final bool successfullyRegistered;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.masjidName,
    required this.pincode,

    required this.successfullyRegistered,
  });

  factory Admin.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Admin(
      id: doc.id,
      name: data['imamName'] ?? '',
      email: data['email'] ?? '',
      phone: data['mobileNumber'] ?? '',
      masjidName: data['masjidName'] ?? '',
      pincode: data['pinCode'] ?? '',
      address: data['address'] ?? '',
      successfullyRegistered: data['successfullyRegistered'] ?? false,
    );
  }


  Admin copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? masjidName,
    String? pincode,
    String? address,
    bool? isActive,
    bool? successfullyRegistered,
  }) {
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      masjidName: masjidName ?? this.masjidName,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      successfullyRegistered: successfullyRegistered ?? this.successfullyRegistered,
    );
  }
}