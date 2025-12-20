import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/provider/signup_provider.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';
import 'package:rafahiyatourism/view/auth/login_screen.dart';

import '../../utils/language/app_strings.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    final isTablet = screenWidth > 600;
    final provider = Provider.of<SignupProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

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
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
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
                            padding: EdgeInsets.only(
                              left: screenWidth * 0.05,
                              top: screenHeight * 0.06,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Container(
                                    height: screenHeight * 0.04,
                                    width: screenHeight * 0.04,
                                    decoration: BoxDecoration(
                                      color: Colors.white54,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.back,
                                      color: Colors.white,
                                      size: screenHeight * 0.025,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: screenWidth * 0.03),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppStrings.getString('userDetails', currentLocale),
                                        style: GoogleFonts.poppins(
                                          fontSize: isTablet ? 32 : isSmallScreen ? 20 : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
                                            child: provider.profileImage != null
                                                ? Image.file(
                                              provider.profileImage!,
                                              height: isTablet ? 120 : screenHeight * 0.12,
                                              width: isTablet ? 120 : screenHeight * 0.12,
                                              fit: BoxFit.cover,
                                            )
                                                : Image.asset(
                                              'assets/images/user.png',
                                              height: isTablet ? 120 : screenHeight * 0.12,
                                              width: isTablet ? 120 : screenHeight * 0.12,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -5,
                                            left: -5,
                                            child: InkWell(
                                              onTap: () {
                                                provider.showImagePickerBottomSheet(context);
                                              },
                                              child: Container(
                                                height: isTablet ? 50 : screenHeight * 0.04,
                                                width: isTablet ? 50 : screenHeight * 0.04,
                                                decoration: BoxDecoration(
                                                  color: AppColors.mainColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                    size: isTablet ? 30 : screenHeight * 0.02,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                              child: Column(
                                children: [
                                  SizedBox(height: screenHeight * 0.02),
                                  if (provider.errorMessage != null)
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(12),
                                      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
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
                                          IconButton(
                                            icon: Icon(Icons.close, color: Colors.red[800]),
                                            onPressed: () => provider.clearError(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  CustomTextFormField(
                                    controller: provider.fullNameController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('fullName', currentLocale),
                                    prefixIcon: Icon(Icons.person, color: AppColors.mainColor),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  CustomTextFormField(
                                    controller: provider.pinCodeController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('pincode', currentLocale),
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icon(Icons.pin_drop, color: AppColors.mainColor),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  CustomTextFormField(
                                    controller: provider.mobileNumberController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('mobileNumber', currentLocale),
                                    keyboardType: TextInputType.phone,
                                    prefixIcon: Icon(Icons.phone, color: AppColors.mainColor),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  CustomTextFormField(
                                    controller: provider.emailController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('emailId', currentLocale),
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icon(Icons.mail, color: AppColors.mainColor),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  CustomTextFormField(
                                    controller: provider.cityController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('city', currentLocale),
                                    prefixIcon: Icon(Icons.location_city, color: AppColors.mainColor),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Container(
                                    width: double.infinity,
                                    height: screenHeight * 0.07,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: provider.selectedCountry,
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
                                      style: GoogleFonts.poppins(color: Colors.black87),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          provider.setCountry(newValue);
                                        }
                                      },
                                      items: provider.countries.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),

                                  SizedBox(height: screenHeight * 0.015),
                                  Consumer<SignupProvider>(
                                    builder: (context, provider, _) => CustomTextFormField(
                                      controller: provider.passwordController,
                                      textInputAction: TextInputAction.next,
                                      labelText: AppStrings.getString('password', currentLocale),
                                      isPassword: provider.isPasswordObscure,
                                      prefixIcon: Icon(Icons.password, color: AppColors.mainColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(provider.isPasswordObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: provider.togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.015),
                                  Consumer<SignupProvider>(
                                    builder: (context, provider, _) => CustomTextFormField(
                                      controller: provider.confirmPasswordController,
                                      textInputAction: TextInputAction.next,
                                      labelText: AppStrings.getString('confirmPassword', currentLocale),
                                      isPassword: provider.isConfirmPasswordObscure,
                                      prefixIcon: Icon(Icons.password, color: AppColors.mainColor),
                                      suffixIcon: IconButton(
                                        icon: Icon(provider.isConfirmPasswordObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        onPressed: provider.toggleConfirmPasswordVisibility,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.03),
                                  Consumer<SignupProvider>(
                                    builder: (context, provider, _) => InkWell(
                                      onTap: provider.isLoading
                                          ? null
                                          : () async {
                                        bool success = await provider.registerUser(context);
                                        if (success) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => LoginScreen()),
                                          );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppStrings.getString('registrationSuccessful', currentLocale),
                                                style: GoogleFonts.poppins(),
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        height: screenHeight * 0.06,
                                        width: screenWidth * 0.5,
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
                                            AppStrings.getString('signUp', currentLocale),
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: isTablet ? 26 : isSmallScreen ? 15 : 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${AppStrings.getString('alreadyHaveAccount', currentLocale)} ',
                                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => LoginScreen()),
                                          );
                                        },
                                        child: Text(
                                          AppStrings.getString('login', currentLocale),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.mainColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}