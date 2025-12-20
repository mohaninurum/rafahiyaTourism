import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/const/toast_services.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../provider/forgot_password_provider.dart';
import '../../utils/language/app_strings.dart';

class UserForgotPassword extends StatelessWidget {
  const UserForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ForgotPasswordProvider(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Consumer<ForgotPasswordProvider>(
                builder: (context, provider, child) {
                  final localeProvider = Provider.of<LocaleProvider>(context);
                  final currentLocale = localeProvider.locale?.languageCode ?? 'en';

                  return Column(
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
                            AppStrings.getString('forgotPassword', currentLocale),
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
                          height: 150,
                          width: 150,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/forgot_icon.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                      Text(
                        AppStrings.getString('enterEmailForReset', currentLocale),
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
                        controller: provider.emailController,
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
                              color: AppColors.whiteColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(height: 50),
                      provider.isLoading
                          ? SpinKitChasingDots(
                        color: AppColors.whiteColor,
                      )
                          : ElevatedButton(
                        onPressed: () async {
                          final success = await provider.sendPasswordResetEmail(context);
                          if (success) {
                            ToastService.showSuccess(provider.successMessage!);
                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.pop(context);
                            });
                          } else if (provider.errorMessage != null) {
                            ToastService.showError(provider.errorMessage!);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          AppStrings.getString('sendResetLink', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}