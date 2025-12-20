// models/user_model.dart
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String pincode;
  final String joinDate;
  final String status;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.pincode,
    required this.joinDate,
    required this.status,
    this.profileImage,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      pincode: map['pincode'] ?? '',
      joinDate: map['joinDate'] ?? '',
      status: map['status'] ?? 'Active',
      profileImage: map['profileImage'],
    );
  }
}