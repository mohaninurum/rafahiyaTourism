// providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:rafahiyatourism/utils/model/user_model.dart';

class UserProvider with ChangeNotifier {
  final List<User> _users = [
    User(
      id: '1',
      name: 'Ahmed Khan',
      email: 'ahmed@example.com',
      phone: '+92 300 1234567',
      pincode: '54000',
      joinDate: '2023-05-15',
      status: 'Active',
      profileImage: 'assets/images/user.png',
    ),
    User(
      id: '2',
      name: 'Fatima Ali',
      email: 'fatima@example.com',
      phone: '+92 300 7654321',
      pincode: '54301',
      joinDate: '2023-05-16',
      status: 'Active',
      profileImage: 'assets/images/user.png',
    ),
    // Add more sample users
  ];

  List<User> get users => _users;

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(String userId, User updatedUser) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = updatedUser;
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }
}