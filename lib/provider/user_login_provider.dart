import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/services/splash_services.dart';
import 'package:rafahiyatourism/view/bottom_navigation_bar.dart';
import '../services/notification_services.dart';
import '../utils/language/app_strings.dart';
import '../utils/model/auth/auth_user_model.dart';
import '../view/auth/google_sigin_detailScreen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class UserLoginProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isPasswordObscure = true;
  bool _isLoading = false;
  String? _errorMessage;
  AuthUserModel? _currentUser;

  bool get isPasswordObscure => _isPasswordObscure;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthUserModel? get currentUser => _currentUser;

  void togglePasswordVisibility() {
    _isPasswordObscure = !_isPasswordObscure;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserData() async {
    _currentUser = await SplashServices.getUserData();
    notifyListeners();
  }


  Future<Map<String, tz.Location>> setupTimezone() async {
    var locations = tz.timeZoneDatabase.locations;
    return locations;
  }



  // Future<void> savePlayerIdToFirestore(String uid, String collectionName) async {
  //   try {
  //
  //     final permission = await OneSignal.Notifications.requestPermission(true);
  //
  //     if (!permission) {
  //       print("⚠️ Notification permission not granted");
  //       return;
  //     }
  //
  //     final deviceState = await OneSignal.User.getOnesignalId();
  //
  //     if (deviceState != null && deviceState.isNotEmpty) {
  //       await FirebaseFirestore.instance
  //           .collection(collectionName)
  //           .doc(uid)
  //           .update({
  //         'playerId': deviceState,
  //         'playerIdUpdatedAt': FieldValue.serverTimestamp()
  //       });
  //
  //       print("✅ Player ID updated for $collectionName: $deviceState");
  //     } else {
  //       print("⚠️ Player ID is null or empty. Retrying in 3 seconds...");
  //
  //       await Future.delayed(Duration(seconds: 3));
  //       final retryDeviceState = await OneSignal.User.getOnesignalId();
  //
  //       if (retryDeviceState != null && retryDeviceState.isNotEmpty) {
  //         await FirebaseFirestore.instance
  //             .collection(collectionName)
  //             .doc(uid)
  //             .update({
  //           'playerId': retryDeviceState,
  //           'playerIdUpdatedAt': FieldValue.serverTimestamp()
  //         });
  //         print("✅ Player ID updated on retry: $retryDeviceState");
  //       } else {
  //         print("❌ Failed to get Player ID even after retry");
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Error saving Player ID: $e");
  //
  //     try {
  //       final playerId = OneSignal.User.pushSubscription.id;
  //       if (playerId != null && playerId.isNotEmpty) {
  //         await FirebaseFirestore.instance
  //             .collection(collectionName)
  //             .doc(uid)
  //             .update({'playerId': playerId});
  //         print("✅ Player ID updated using fallback: $playerId");
  //       }
  //     } catch (fallbackError) {
  //       print("❌ Fallback method also failed: $fallbackError");
  //     }
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



  Future<void> _fetchUserData(String uid, BuildContext context) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = AuthUserModel.fromMap(userDoc.data()!, userDoc.id);
        await SplashServices.saveUserData(_currentUser!);
      } else {
        final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
        final currentLocale = localeProvider.locale?.languageCode ?? 'en';

        final newUser = AuthUserModel(
          country: '',
          id: uid,
          fullName: _auth.currentUser?.displayName ?? AppStrings.getString('newUser', currentLocale),
          pinCode: '',
          mobileNumber: _auth.currentUser?.phoneNumber ?? '',
          city: '',
          email: _auth.currentUser?.email ?? emailController.text.trim(),
        );
        await _firestore.collection('users').doc(uid).set(newUser.toMap());
        _currentUser = newUser;
        await SplashServices.saveUserData(_currentUser!);
      }
      notifyListeners();
    } catch (e) {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final currentLocale = localeProvider.locale?.languageCode ?? 'en';
      setErrorMessage(AppStrings.getString('failedFetchUserData', currentLocale));
      throw Exception('Failed to fetch user data: $e');
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    _isLoading = true;
    clearError();
    notifyListeners();

    try {

      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        // User exists - complete login
        // await NotificationService.initialize(currentUserId: userCredential.user!.uid, collectionName: "users");
        // Wait for OneSignal to be ready and save player ID FIRST
        await savePlayerIdToFirestore(user.uid, 'users');

        if (userDoc.exists) {
          // Existing user
          await _fetchUserData(user.uid, context);
          await SplashServices.saveLoginData(true);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: this,
                child: BottomNavigation(user: _currentUser),
              ),
            ),
          );
        } else {
          // New user - navigate to completion screen
          final newUser = AuthUserModel(
            country: '',
            id: user.uid,
            fullName: user.displayName ?? AppStrings.getString('googleUser', currentLocale),
            pinCode: '',
            mobileNumber: user.phoneNumber ?? '',
            city: '',
            email: user.email ?? '',
            profileImage: user.photoURL,
          );

          _currentUser = newUser;
          await SplashServices.saveUserData(_currentUser!);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChangeNotifierProvider.value(
                value: this,
                child: GoogleSignupCompletionScreen(user: newUser),
              ),
            ),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      setErrorMessage('${AppStrings.getString('googleSignInFailed', currentLocale)}: ${e.toString()}');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> _ensurePlayerIdSaved(String uid, String collectionName) async {
  //   try {
  //     // Give OneSignal some time to initialize
  //     await Future.delayed(const Duration(seconds: 1));
  //
  //     // Try multiple times to get the player ID
  //     String? playerId;
  //     int attempts = 0;
  //
  //     while (playerId == null && attempts < 5) {
  //       playerId = OneSignal.User.pushSubscription.id;
  //       if (playerId == null) {
  //         await Future.delayed(const Duration(milliseconds: 500));
  //         attempts++;
  //       }
  //     }
  //
  //     if (playerId != null && playerId.isNotEmpty) {
  //       await _firestore
  //           .collection(collectionName)
  //           .doc(uid)
  //           .update({
  //         'playerId': playerId,
  //         'playerIdUpdatedAt': FieldValue.serverTimestamp()
  //       });
  //       print("✅ Player ID saved successfully: $playerId");
  //     } else {
  //       print("⚠️ Could not get Player ID after multiple attempts");
  //
  //       // Schedule a retry after 5 seconds
  //       Future.delayed(const Duration(seconds: 5), () async {
  //         final retryPlayerId = OneSignal.User.pushSubscription.id;
  //         if (retryPlayerId != null && retryPlayerId.isNotEmpty) {
  //           await _firestore
  //               .collection(collectionName)
  //               .doc(uid)
  //               .update({'playerId': retryPlayerId});
  //           print("✅ Player ID saved on retry: $retryPlayerId");
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     print("❌ Error ensuring player ID saved: $e");
  //
  //     // Final fallback - try one more time after a delay
  //     Future.delayed(const Duration(seconds: 3), () async {
  //       try {
  //         final fallbackPlayerId = OneSignal.User.pushSubscription.id;
  //         if (fallbackPlayerId != null && fallbackPlayerId.isNotEmpty) {
  //           await _firestore
  //               .collection(collectionName)
  //               .doc(uid)
  //               .update({'playerId': fallbackPlayerId});
  //           print("✅ Player ID saved with fallback: $fallbackPlayerId");
  //         }
  //       } catch (e) {
  //         print("❌ Fallback also failed: $e");
  //       }
  //     });
  //   }
  // }

  Future<bool> loginUser(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (!_validateForm(currentLocale)) {
      return false;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        setErrorMessage(AppStrings.getString('noUserFound', currentLocale));
        return false;
      }

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      // User exists - complete login
      // await NotificationService.initialize(currentUserId: userCredential.user!.uid, collectionName: "users");

      // Save player ID FIRST before navigation
      await savePlayerIdToFirestore(userCredential.user!.uid, 'users');

      await _fetchUserData(userCredential.user!.uid, context);
      await SplashServices.saveLoginData(true);

      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: this,
            child: BottomNavigation(user: _currentUser),
          ),
        ),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e, currentLocale);
      return false;
    } catch (e) {
      setErrorMessage(AppStrings.getString('unexpectedError', currentLocale));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeGoogleSignup(
      BuildContext context,
      String mobileNumber,
      String pinCode,
      String city,
      String country,
      ) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final updatedUser = _currentUser!.copyWith(
        mobileNumber: mobileNumber,
        pinCode: pinCode,
        city: city,
        country: country,
      );

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .set(updatedUser.toMap());

      _currentUser = updatedUser;
      await SplashServices.saveUserData(_currentUser!);
      // await NotificationService.initialize(currentUserId: _currentUser!.id!, collectionName: "users");
      await savePlayerIdToFirestore(_currentUser!.id!, 'users');
      await SplashServices.saveLoginData(true);



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: this,
            child: BottomNavigation(user: _currentUser),
          ),
        ),
      );
    } catch (e) {
      setErrorMessage(AppStrings.getString('failedCompleteRegistration', currentLocale));
      throw Exception('Failed to complete registration: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> signOut(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentUser = null;
      await SplashServices.clearUserData();
      notifyListeners();
    } catch (e) {
      setErrorMessage('${AppStrings.getString('errorSigningOut', currentLocale)}: ${e.toString()}');
    }
  }

  Future<void> updateUserProfile(AuthUserModel updatedUser, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('users')
          .doc(_currentUser!.id)
          .update(updatedUser.toMap());

      _currentUser = updatedUser;
      await SplashServices.saveUserData(_currentUser!);
      notifyListeners();
    } catch (e) {
      setErrorMessage(AppStrings.getString('failedUpdateProfile', currentLocale));
      throw Exception('Failed to update profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _validateForm(String languageCode) {
    if (emailController.text.trim().isEmpty) {
      setErrorMessage(AppStrings.getString('enterEmail', languageCode));
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      setErrorMessage(AppStrings.getString('enterPassword', languageCode));
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      setErrorMessage(AppStrings.getString('enterValidEmail', languageCode));
      return false;
    }

    return true;
  }

  void _handleFirebaseError(FirebaseAuthException e, String languageCode) {
    switch (e.code) {
      case 'user-not-found':
        setErrorMessage(AppStrings.getString('noUserFound', languageCode));
        break;
      case 'wrong-password':
        setErrorMessage(AppStrings.getString('incorrectPassword', languageCode));
        break;
      case 'invalid-email':
        setErrorMessage(AppStrings.getString('invalidEmail', languageCode));
        break;
      case 'user-disabled':
        setErrorMessage(AppStrings.getString('accountDisabled', languageCode));
        break;
      case 'too-many-requests':
        setErrorMessage(AppStrings.getString('tooManyAttempts', languageCode));
        break;
      case 'operation-not-allowed':
        setErrorMessage(AppStrings.getString('operationNotAllowed', languageCode));
        break;
      default:
        setErrorMessage('${AppStrings.getString('loginError', languageCode)}: ${e.message}');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}