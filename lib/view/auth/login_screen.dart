import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/provider/user_login_provider.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';
import 'package:rafahiyatourism/view/auth/sign_up_screen.dart';
import 'package:rafahiyatourism/view/auth/user_forgot_password.dart';

import '../../utils/language/app_strings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserLoginProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/container_image.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                // Header container
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/container_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
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
                              color: AppColors.whiteColor,
                              size: 25,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  AppStrings.getString('userLogin', currentLocale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 170, height: 70),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // White content container
                SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 80),
                              if (provider.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    provider.errorMessage!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              CustomTextFormField(
                                controller: provider.emailController,
                                textInputAction: TextInputAction.next,
                                labelText: AppStrings.getString('emailId', currentLocale),
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icon(
                                  Icons.mail,
                                  color: AppColors.mainColor,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Consumer<UserLoginProvider>(
                                builder: (context, provider, child) {
                                  return CustomTextFormField(
                                    controller: provider.passwordController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('password', currentLocale),
                                    isPassword: provider.isPasswordObscure,
                                    prefixIcon: Icon(
                                      Icons.password,
                                      color: AppColors.mainColor,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        provider.isPasswordObscure
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.mainColor,
                                      ),
                                      onPressed: () {
                                        provider.togglePasswordVisibility();
                                      },
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    AppStrings.getString('forgotPassword', currentLocale),
                                    style: GoogleFonts.poppins(
                                      color: AppColors.mainColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () async {
                                  provider.clearError();
                                  bool success = await provider.loginUser(
                                    context,
                                  );

                                  if (!success && provider.errorMessage == null) {
                                    provider.setErrorMessage(
                                      AppStrings.getString('unexpectedError', currentLocale),
                                    );
                                  }
                                },
                                child: provider.isLoading
                                    ? SpinKitChasingDots(
                                  color: AppColors.mainColor,
                                )
                                    : Container(
                                  height: 52,
                                  width: 173,
                                  decoration: BoxDecoration(
                                    color: AppColors.mainColor,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.getString('signIn', currentLocale),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.whiteBackground,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.getString('dontHaveAccount', currentLocale),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppStrings.getString('signUp', currentLocale),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.mainColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                AppStrings.getString('orSignInWith', currentLocale),
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mainColor,
                                ),
                              ),
                              const SizedBox(height: 15),
                              InkWell(
                                onTap: () async {
                                  bool success = await provider.signInWithGoogle(context);
                                  if (!success && provider.errorMessage != null) {
                                    print("google sign in error:-${provider.errorMessage!}");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(provider.errorMessage!),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: 250,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.mainColor),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/google.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppStrings.getString('signInWithGoogle', currentLocale),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.mainColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 20,
                          top: -120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/images/image.jpg',
                              height: 176,
                              width: 141,
                              fit: BoxFit.cover,
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
}