import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../../const/color.dart';
import '../../../provider/add_sub_super_admin_provider.dart';
import '../../../utils/widgets/custom_form_filed.dart';

class AddSuperAdminScreen extends StatefulWidget {
  const AddSuperAdminScreen({super.key});

  @override
  State<AddSuperAdminScreen> createState() => _AddSuperAdminScreenState();
}

class _AddSuperAdminScreenState extends State<AddSuperAdminScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AddSubSuperAdminProvider>(context);
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          AppStrings.getString('addNewSuperAdmin', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(currentLocale),
            const SizedBox(height: 32),
            CustomFormField(
              controller: _nameController,
              label: AppStrings.getString('fullName', currentLocale),
              hint: AppStrings.getString('enterFullName', currentLocale),
              icon: Icons.person,
              errorText: provider.nameError,
              onChanged: (value) => provider.validateName(value),
            ),
            const SizedBox(height: 20),
            CustomFormField(
              controller: _emailController,
              label: AppStrings.getString('emailAddress', currentLocale),
              hint: AppStrings.getString('enterEmailAddress', currentLocale),
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              errorText: provider.emailError,
              onChanged: (value) => provider.validateEmail(value),
            ),
            const SizedBox(height: 20),
            CustomFormField(
              controller: _phoneController,
              label: AppStrings.getString('phoneNumber', currentLocale),
              hint: AppStrings.getString('enterPhoneNumber', currentLocale),
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              errorText: provider.phoneError,
              onChanged: (value) => provider.validatePhone(value),
            ),
            const SizedBox(height: 20),
            CustomFormField(
              controller: _passwordController,
              label: AppStrings.getString('password', currentLocale),
              hint: AppStrings.getString('createStrongPassword', currentLocale),
              icon: Icons.lock,
              obscureText: true,
              errorText: provider.passwordError,
              onChanged: (value) => provider.validatePassword(value),
            ),
            const SizedBox(height: 32),
            _buildSubmitButton(provider, currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String currentLocale) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.admin_panel_settings,
            size: 50,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppStrings.getString('createNewSuperAdmin', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getString('addSuperAdminDescription', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AddSubSuperAdminProvider provider, String currentLocale) {
    return ElevatedButton(
      onPressed: provider.isLoading
          ? null
          : () async {
        final success = await provider.createSuperAdmin(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (success && mounted) {
          _showSuccessDialog(currentLocale);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: provider.isLoading ? Colors.grey : AppColors.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: provider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        AppStrings.getString('createSuperAdmin', currentLocale),
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showSuccessDialog(String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          AppStrings.getString('success', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.mainColor,
          ),
        ),
        content: Text(
          AppStrings.getString('superAdminCreatedSuccess', currentLocale),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              AppStrings.getString('ok', currentLocale),
              style: GoogleFonts.poppins(
                color: AppColors.mainColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}