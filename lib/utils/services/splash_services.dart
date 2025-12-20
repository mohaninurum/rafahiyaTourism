import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/view/auth/intro_slider.dart';
import 'package:rafahiyatourism/view/bottom_navigation_bar.dart';
import 'package:rafahiyatourism/view/admin_side_code/admin_bottom_navigationbar.dart';
import 'package:rafahiyatourism/view/super_admin_code/super_admin_navbar.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_login_provider.dart';

import '../../provider/user_login_provider.dart';

class SplashServices {
  Future<bool> checkLogin(BuildContext context) async {
    final adminProvider = Provider.of<AdminsLoginProvider>(context, listen: false);
    final userProvider = Provider.of<UserLoginProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isLoggedInAdmin = await adminProvider.checkLoggedInStatus();

    if (isLoggedIn) {
      print("isLoggedIn..........->>");
       await FirebaseMessaging.instance.subscribeToTopic("notificationAll");
      await userProvider.loadUserData();
    }

    if (isLoggedInAdmin) {
      if (adminProvider.userType == 'superadmin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SuperAdminBottomNavigationBar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminBottomNavigationBar()),
        );
      }
    } else if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: userProvider,
            child: BottomNavigation(user: userProvider.currentUser),
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    }

    return isLoggedInAdmin || isLoggedIn;
  }

  static Future<void> saveLoginData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<bool> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> saveUserData(AuthUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', json.encode(user.toJson()));
  }

  static Future<AuthUserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    if (userData != null) {
      return AuthUserModel.fromJson(json.decode(userData));
    }
    return null;
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    await prefs.setBool('isLoggedIn', false);
  }
}