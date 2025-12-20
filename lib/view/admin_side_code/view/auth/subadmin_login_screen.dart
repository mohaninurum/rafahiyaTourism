import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_login_provider.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/auth/sub_admin_register_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/auth/subadmin_forgot_password.dart';

import '../../../../utils/language/app_strings.dart';
import '../../data/utils/circular_indicator_spinkit.dart';

class SubAdminLoginScreen extends StatefulWidget {
  const SubAdminLoginScreen({super.key});

  @override
  State<SubAdminLoginScreen> createState() => _SubAdminLoginScreenState();
}

class _SubAdminLoginScreenState extends State<SubAdminLoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Consumer<AdminsLoginProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
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
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/container_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              Column(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
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
                                    provider.userType == 'superadmin'
                                        ? AppStrings.getString('superAdminLogin', currentLocale)
                                        : AppStrings.getString('adminLogin', currentLocale),
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 170, height: 70),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 80),
                                  if (provider.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        provider.errorMessage!,
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  CustomTextFormField(
                                    controller: provider.userType == 'superadmin'
                                        ? provider.superAdminEmailController
                                        : provider.subAdminEmailController,
                                    textInputAction: TextInputAction.next,
                                    labelText: AppStrings.getString('emailId', currentLocale),
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icon(
                                      Icons.mail,
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  CustomTextFormField(
                                    controller: provider.userType == 'superadmin'
                                        ? provider.superAdminPasswordController
                                        : provider.subAdminPasswordController,
                                    textInputAction: TextInputAction.done,
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
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'subadmin',
                                            groupValue: provider.userType,
                                            onChanged: (value) {
                                              provider.setUserType(value!);
                                            },
                                            activeColor: AppColors.mainColor,
                                          ),
                                          Text(
                                            AppStrings.getString('subAdmin', currentLocale),
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Radio<String>(
                                            value: 'superadmin',
                                            groupValue: provider.userType,
                                            onChanged: (value) {
                                              provider.setUserType(value!);
                                            },
                                            activeColor: AppColors.mainColor,
                                          ),
                                          Text(
                                            AppStrings.getString('superAdmin', currentLocale),
                                            style: GoogleFonts.poppins(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (provider.userType == 'subadmin') ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                              const SubAdminForgotPassword(),
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
                                    if (provider.isLoading)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: CustomCircularProgressIndicator(
                                          size: 30.0,
                                          color: AppColors.mainColor,
                                          spinKitType: SpinKitType.chasingDots,
                                        ),
                                      )
                                    else
                                      InkWell(
                                        onTap: () {
                                          provider.setErrorMessage(null);
                                          provider.subAdminLogin(context);
                                        },
                                        child: Container(
                                          height: 52,
                                          width: 173,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainColor,
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppStrings.getString('signIn', currentLocale),
                                              style: GoogleFonts.poppins(
                                                color:
                                                AppColors.whiteBackground,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
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
                                                builder: (context) =>
                                                const AdminRegisterScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            AppStrings.getString('signUpHere', currentLocale),
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
                                  ] else if (provider.userType ==
                                      'superadmin') ...[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=> SubAdminForgotPassword()));
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
                                    if (provider.isLoading)
                                      CustomCircularProgressIndicator(
                                        size: 30.0,
                                        color: AppColors.mainColor,
                                        spinKitType: SpinKitType.chasingDots,
                                      )
                                    else
                                      InkWell(
                                        onTap: () {
                                          provider.setErrorMessage(null);
                                          provider.handleLogin(context);
                                        },
                                        child: Container(
                                          height: 52,
                                          width: 173,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainColor,
                                            borderRadius:
                                            BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppStrings.getString('signIn', currentLocale),
                                              style: GoogleFonts.poppins(
                                                color:
                                                AppColors.whiteBackground,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                  const SizedBox(height: 30),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: -120,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
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
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}