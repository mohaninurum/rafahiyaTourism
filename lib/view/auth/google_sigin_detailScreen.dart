import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/provider/user_login_provider.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';

import '../../utils/language/app_strings.dart';

class GoogleSignupCompletionScreen extends StatefulWidget {
  final AuthUserModel user;

  const GoogleSignupCompletionScreen({super.key, required this.user});

  @override
  State<GoogleSignupCompletionScreen> createState() => _GoogleSignupCompletionScreenState();
}

class _GoogleSignupCompletionScreenState extends State<GoogleSignupCompletionScreen> {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? _selectedCountry;

  final List<String> _countries = [
    'Saudi Arabia',
    'United Arab Emirates',
    'Qatar',
    'Germany',
    'Kuwait',
    'Oman',
    'Bahrain',
    'Egypt',
    'Jordan',
    'Palestine',
    'Morocco',
    'Turkey',
    'Indonesia',
    'Malaysia',
    'Pakistan',
    'India',
    'Bangladesh',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserLoginProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              "assets/images/container_image.png",
              height: screenHeight * 0.15,
              fit: BoxFit.fill,
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.23,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/container_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, top: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              CupertinoIcons.back,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 20, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.getString('completeProfile', currentLocale),
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: widget.user.profileImage != null && widget.user.profileImage!.isNotEmpty
                                    ? NetworkImage(widget.user.profileImage!)
                                    : AssetImage('assets/images/user.png') as ImageProvider,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.getStringWithParams('welcomeUser', currentLocale, {'name': widget.user.fullName}),
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mainColor,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          AppStrings.getString('completeProfileMessage', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                        if (provider.errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            margin: EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red[800]),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    provider.errorMessage!,
                                    style: GoogleFonts.poppins(color: Colors.red[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // Country Dropdown
                        Container(
                          width: double.infinity,
                          height: isTablet ? 60 : 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCountry,
                            hint: Text(
                              AppStrings.getString('chooseCountry', currentLocale),
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.mainColor,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            underline: const SizedBox(),
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontSize: isTablet ? 18 : 16,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCountry = newValue;
                                });
                              }
                            },
                            items: _countries.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: GoogleFonts.poppins(
                                    fontSize: isTablet ? 18 : 16,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 15),
                        CustomTextFormField(
                          controller: mobileNumberController,
                          textInputAction: TextInputAction.next,
                          labelText: AppStrings.getString('mobileNumber', currentLocale),
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(Icons.phone, color: AppColors.mainColor),
                        ),
                        SizedBox(height: 15),
                        CustomTextFormField(
                          controller: pinCodeController,
                          textInputAction: TextInputAction.next,
                          labelText: AppStrings.getString('pincode', currentLocale),
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(Icons.pin_drop, color: AppColors.mainColor),
                        ),
                        SizedBox(height: 15),
                        CustomTextFormField(
                          controller: cityController,
                          textInputAction: TextInputAction.done,
                          labelText: AppStrings.getString('city', currentLocale),
                          prefixIcon: Icon(Icons.location_city, color: AppColors.mainColor),
                        ),
                        SizedBox(height: 30),
                        InkWell(
                          onTap: provider.isLoading
                              ? null
                              : () async {
                            if (_validateForm(context)) {
                              await provider.completeGoogleSignup(
                                context,
                                mobileNumberController.text.trim(),
                                pinCodeController.text.trim(),
                                cityController.text.trim(),
                                _selectedCountry!, // Pass selected country
                              );
                            }
                          },
                          child: Container(
                            height: 52,
                            width: 200,
                            decoration: BoxDecoration(
                              color: provider.isLoading
                                  ? AppColors.mainColor.withOpacity(0.7)
                                  : AppColors.mainColor,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: provider.isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                AppStrings.getString('completeSignUp', currentLocale),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _validateForm(BuildContext context) {
    final provider = Provider.of<UserLoginProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    // Validate country
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      provider.setErrorMessage(AppStrings.getString('selectCountry', currentLocale));
      return false;
    }

    if (mobileNumberController.text.trim().isEmpty) {
      provider.setErrorMessage(AppStrings.getString('enterMobileNumber', currentLocale));
      return false;
    } else if (!RegExp(r'^[0-9]{10,15}$').hasMatch(mobileNumberController.text.trim())) {
      provider.setErrorMessage(AppStrings.getString('enterValidMobile', currentLocale));
      return false;
    }

    if (pinCodeController.text.trim().isEmpty) {
      provider.setErrorMessage(AppStrings.getString('enterPincode', currentLocale));
      return false;
    }

    if (cityController.text.trim().isEmpty) {
      provider.setErrorMessage(AppStrings.getString('enterCity', currentLocale));
      return false;
    }

    provider.clearError();
    return true;
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    pinCodeController.dispose();
    cityController.dispose();
    super.dispose();
  }
}