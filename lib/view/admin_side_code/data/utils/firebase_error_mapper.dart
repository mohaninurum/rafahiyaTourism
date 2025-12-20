// helpers/firebase_error_mapper.dart
import 'package:firebase_auth/firebase_auth.dart';

String mapFirebaseAuthError(FirebaseAuthException e) {
  switch (e.code) {
    case 'user-not-found':
      return 'No user found with this email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-email':
      return 'Invalid email format.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    default:
      return e.message ?? 'Login failed. Please try again.';
  }
}
