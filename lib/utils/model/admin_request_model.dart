// lib/models/admin_request.dart
class AdminRequest {
  final String name;
  final String email;
  final String date;
  final String phone;
  final String masjid;
  final String pincode;
  final String address;

  const AdminRequest({
    required this.name,
    required this.email,
    required this.date,
    this.phone = "+92 300 1234567",
    this.masjid = "Masjid Al-Haram",
    this.pincode = "54000",
    this.address = "123 Main Street, Makkah",
  });
}