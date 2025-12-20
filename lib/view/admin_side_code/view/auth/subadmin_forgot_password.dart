import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../data/subAdminProvider/sub_admin_forgot_password_provider.dart';

class SubAdminForgotPassword extends StatefulWidget {
  const SubAdminForgotPassword({super.key});

  @override
  State<SubAdminForgotPassword> createState() => _SubAdminForgotPasswordState();
}

class _SubAdminForgotPasswordState extends State<SubAdminForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubAdminForgotPasswordProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Row(
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
                      const SizedBox(width: 100),
                      Text(
                        AppStrings.getString('forgotPasswordTitle', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/forgot.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.getString('pleaseEnterEmail', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    AppStrings.getString('email', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: AppStrings.getString('email', currentLocale),
                      prefixIcon: Icon(Icons.mail, color: AppColors.mainColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                      final currentLocale = localeProvider.locale?.languageCode ?? 'en';
                      return Provider.of<SubAdminForgotPasswordProvider>(context, listen: false)
                          .validateEmail(value ?? '', languageCode: currentLocale);
                    },
                    onChanged: (value) {
                      // Clear error message when user starts typing
                      if (provider.errorMessage != null) {
                        provider.clearErrorMessage();
                      }
                    },
                  ),
                  if (provider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        provider.errorMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  if (provider.successMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        provider.successMessage!,
                        style: GoogleFonts.poppins(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  if (provider.isLoading)
                    Center(
                      child: SpinKitChasingDots(
                        color: AppColors.whiteColor,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          provider.resetPassword(context, _emailController.text.trim());
                        }
                      },
                      child: Container(
                        height: 52,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(25)
                        ),
                        child: Center(
                          child: Text(
                            AppStrings.getString('sendResetLink', currentLocale),
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteBackground,
                              fontSize: 22,
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
        ),
      ),
    );
  }
}