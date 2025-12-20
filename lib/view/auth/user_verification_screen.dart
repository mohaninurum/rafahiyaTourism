import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../const/toast_services.dart';

class UserVerificationCodeScreen extends StatefulWidget {
  final String email;

  const UserVerificationCodeScreen({super.key, required this.email});

  @override
  State<UserVerificationCodeScreen> createState() => _UserVerificationCodeScreenState();
}

class _UserVerificationCodeScreenState extends State<UserVerificationCodeScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ToastService.showError('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email == widget.email) {
        await user.updatePassword(_newPasswordController.text);
        ToastService.showSuccess('Password updated successfully');
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ToastService.showError('Please verify your email first');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'requires-recent-login':
          message = 'Please re-authenticate to update password';
          break;
        default:
          message = 'Error updating password: ${e.message}';
      }
      ToastService.showError(message);
    } catch (e) {
      ToastService.showError('An unexpected error occurred');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Reset password for ${widget.email}'),
              SizedBox(height: 20),

              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter new password';
                  if (value.length < 6) return 'Password must be 6+ characters';
                  return null;
                },
              ),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30),

              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _updatePassword,
                child: Text('Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}