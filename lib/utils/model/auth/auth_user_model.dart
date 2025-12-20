import 'package:cloud_firestore/cloud_firestore.dart';

class AuthUserModel {
  final String? id;
  final String fullName;
  final String pinCode;
  final String mobileNumber;
  final String city;
  final String email;
  final String? profileImage;
  final DateTime? createdAt;
  final String country;
  String? playerId;

  AuthUserModel({
    this.id,
    required this.country,
    required this.fullName,
    required this.pinCode,
    required this.mobileNumber,
    required this.city,
    required this.email,
    this.profileImage,
    this.playerId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': country,
      'fullName': fullName,
      'pinCode': pinCode,
      'mobileNumber': mobileNumber,
      'city': city,
      'email': email,
      'profileImage': profileImage,
      'playerId': playerId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'],
      country: json['country'],
      fullName: json['fullName'],
      pinCode: json['pinCode'],
      mobileNumber: json['mobileNumber'],
      city: json['city'],
      email: json['email'],
      profileImage: json['profileImage'],
      playerId: json['playerId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'pinCode': pinCode,
      'mobileNumber': mobileNumber,
      'city': city,
      'country': country,
      'email': email,
      'profileImage': profileImage ?? '',
      'playerId': playerId,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map, String id) {
    return AuthUserModel(
      id: id,
      country: map['country'],
      fullName: map['fullName'] ?? '',
      pinCode: map['pinCode'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      city: map['city'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'],
      playerId: map['playerId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  AuthUserModel copyWith({
    String? id,
    String? fullName,
    String? pinCode,
    String? mobileNumber,
    String? city,
    String? email,
    String? profileImage,
    DateTime? createdAt,
    String? country,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      country: country ?? this.country,
      fullName: fullName ?? this.fullName,
      pinCode: pinCode ?? this.pinCode,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      city: city ?? this.city,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      playerId: playerId ?? this.playerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'AuthUserModel{id: $id, fullName: $fullName, email: $email, mobileNumber: $mobileNumber}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AuthUserModel &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              fullName == other.fullName &&
              email == other.email;

  @override
  int get hashCode => id.hashCode ^ fullName.hashCode ^ email.hashCode;
}