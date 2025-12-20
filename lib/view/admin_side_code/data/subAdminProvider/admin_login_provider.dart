import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/utils/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../super_admin_code/super_admin_navbar.dart';
import '../../admin_bottom_navigationbar.dart';
import '../../../auth/intro_slider.dart';

class AdminsLoginProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController superAdminEmailController =
  TextEditingController();
  final TextEditingController superAdminPasswordController =
  TextEditingController();
  final TextEditingController subAdminEmailController = TextEditingController();
  final TextEditingController subAdminPasswordController =
  TextEditingController();

  bool _isPasswordObscure = true;
  String _userType = 'subadmin';
  String? _errorMessage;
  bool _isLoading = false;

  static const String _userTypeKey = 'admin_user_type';
  static const String _isLoggedInKey = 'admin_is_logged_in';

  bool get isPasswordObscure => _isPasswordObscure;

  String get userType => _userType;

  String? get errorMessage => _errorMessage;

  bool get isLoading => _isLoading;

  AdminsLoginProvider() {
    _loadSavedState();
  }







  // Future<void> savePlayerIdToFirestore(String uid, String collectionName) async {
  //   try {
  //     await OneSignal.Notifications.requestPermission(true);
  //
  //     final playerId = OneSignal.User.pushSubscription.id;
  //     final isSubscribed = OneSignal.User.pushSubscription.optedIn;
  //
  //     if (playerId != null && isSubscribed!) {
  //       await FirebaseFirestore.instance
  //           .collection(collectionName)
  //           .doc(uid)
  //           .update({'playerId': playerId});
  //       print("✅ Player ID updated for $collectionName: $playerId");
  //     } else {
  //       print("⚠️ Player not subscribed or ID null. Make sure notifications are allowed.");
  //     }
  //   } catch (e) {
  //     print("❌ Error saving Player ID: $e");
  //   }
  // }



  Future<void> savePlayerIdToFirestore(String uid, String collectionName) async {
    try {
      // Always request permission first
      await OneSignal.Notifications.requestPermission(true);

      // Wait 2 seconds so OneSignal can generate the ID
      await Future.delayed(Duration(seconds: 2));

      final playerId = OneSignal.User.pushSubscription.id;
      final isSubscribed = OneSignal.User.pushSubscription.optedIn;

      print("🔍 Player ID (after delay): $playerId");
      print("🔍 Is Subscribed: $isSubscribed");

      if (playerId != null && playerId.isNotEmpty && isSubscribed == true) {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(uid)
            .update({'playerId': playerId});

        print("✅ Player ID saved to Firestore: $playerId");
      } else {
        print("⚠️ Player ID still NULL. Will retry on next login/app open.");
      }
    } catch (e) {
      print("❌ Error saving Player ID: $e");
    }
  }




  Future<void> _loadSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    _userType = prefs.getString(_userTypeKey) ?? 'subadmin';
    notifyListeners();
  }

  Future<void> _saveUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTypeKey, type);
  }

  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<bool> checkLoggedInStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  void togglePasswordVisibility() {
    _isPasswordObscure = !_isPasswordObscure;
    notifyListeners();
  }

  void setUserType(String type) {
    _userType = type;
    _saveUserType(type);
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool validateSuperAdminFields() {
    final emailError = superAdminEmailController.text.emailError;
    final passwordError = superAdminPasswordController.text.passwordError;

    if (emailError != null) {
      setErrorMessage(emailError);
      return false;
    }
    if (passwordError != null) {
      setErrorMessage(passwordError);
      return false;
    }
    return true;
  }

  bool validateSubAdminFields() {
    final emailError = subAdminEmailController.text.emailError;
    final passwordError = subAdminPasswordController.text.passwordError;

    if (emailError != null) {
      setErrorMessage(emailError);
      return false;
    }
    if (passwordError != null) {
      setErrorMessage(passwordError);
      return false;
    }
    return true;
  }

  Future<void> handleLogin(BuildContext context) async {
    if (!validateSuperAdminFields()) return;

    setLoading(true);
    setErrorMessage(null);

    try {
      final query =
      await _firestore
          .collection('super_admins')
          .where('email', isEqualTo: superAdminEmailController.text.trim())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setLoading(false);
        setErrorMessage('Not authorized as super admin');
        return;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: superAdminEmailController.text.trim(),
        password: superAdminPasswordController.text.trim(),
      );



      // await NotificationService.initialize(currentUserId: userCredential.user!.uid, collectionName: "super_admins");
      await savePlayerIdToFirestore(userCredential.user!.uid, 'super_admins');


      await _saveLoginState(true);
      await _saveUserType('superadmin');
      clearSuperAdminAllData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SuperAdminBottomNavigationBar()),
      );

      context.showSnackBarMessage(
        'Super Admin login successful',
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? 'Login failed. Try again.');
    } finally {
      setLoading(false);
    }
  }

  void clearAllData(){
    subAdminEmailController.clear();
    subAdminPasswordController.clear();
  }
  void clearSuperAdminAllData(){
    subAdminEmailController.clear();
    subAdminPasswordController.clear();
  }

  Future<void> subAdminLogin(BuildContext context) async {
    if (!validateSubAdminFields()) return;

    setLoading(true);
    setErrorMessage(null);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: subAdminEmailController.text.trim(),
        password: subAdminPasswordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User ID not found.");

      final doc = await _firestore.collection('subAdmin').doc(uid).get();
      if (!doc.exists || !(doc.data()?['successfullyRegistered'] ?? false)) {
        setErrorMessage("Super Admin hasn't approved your profile yet.");
        await _auth.signOut();
        return;
      }

      // await NotificationService.initialize(currentUserId: userCredential.user!.uid, collectionName: "subAdmin");
      await savePlayerIdToFirestore(userCredential.user!.uid, 'subAdmin');
      await _saveLoginState(true);
      await _saveUserType('subadmin');
      clearAllData();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminBottomNavigationBar()),
      );

      context.showSnackBarMessage(
        'Sub Admin login successful',
        backgroundColor: Colors.green,
      );
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? "Login failed. Try again.");
    } finally {
      setLoading(false);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      await _saveLoginState(false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => IntroScreen()),
      );
    } catch (e) {
      setErrorMessage('Error signing out');
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      context.showSnackBarMessage(
        'Password reset email sent to $email',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setErrorMessage(e.message ?? 'Password reset failed');
    } finally {
      setLoading(false);
    }
  }

  @override
  void dispose() {
    superAdminEmailController.dispose();
    superAdminPasswordController.dispose();
    subAdminEmailController.dispose();
    subAdminPasswordController.dispose();
    super.dispose();
  }
}
