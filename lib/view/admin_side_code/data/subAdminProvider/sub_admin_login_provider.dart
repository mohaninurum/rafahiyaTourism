import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rafahiyatourism/view/admin_side_code/admin_bottom_navigationbar.dart';

class SubAdminLoginProvider with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordObscure = true;
  bool isLoading = false;
  String? errorMessage;
  String userType = 'subadmin';

  void togglePasswordVisibility() {
    isPasswordObscure = !isPasswordObscure;
    notifyListeners();
  }

  void setUserType(String value) {
    userType = value;
    notifyListeners();
  }

  Future<void> handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = 'Please enter both email and password.';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User ID not found.");

      final userDoc =
          await FirebaseFirestore.instance
              .collection('subAdmin')
              .doc(uid)
              .get();

      if (!userDoc.exists) {
        errorMessage = "User profile not found.";
        FirebaseAuth.instance.signOut();
      } else {
        final data = userDoc.data()!;
        final isApproved = data['successfullyRegistered'] ?? false;

        if (!isApproved) {
          errorMessage = "Super Admin hasn't approved your profile yet.";
          FirebaseAuth.instance.signOut();
        } else {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AdminBottomNavigationBar()));
        }
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        default:
          errorMessage = "Login failed. ${e.message}";
      }
    } catch (e) {
      errorMessage = "Something went wrong. ${e.toString()}";
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.clear();
    passwordController.clear();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
