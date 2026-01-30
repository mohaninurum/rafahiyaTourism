import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/utils/services/splash_services.dart';
import 'package:rafahiyatourism/view/auth/intro_slider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/view/user_notification_screen.dart';

import '../../../provider/locale_provider.dart';

class AppBarActions extends StatelessWidget {
  final double screenWidth;

  const AppBarActions({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    return Row(
      children: [

        PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: Colors.white,
            size: screenWidth * 0.065,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          onSelected: (String languageCode) {
            localeProvider.setLocale(languageCode);
          },
          itemBuilder: (BuildContext context) {
            return localeProvider.supportedLocales.entries.map((entry) {
              return PopupMenuItem<String>(
                value: entry.key,
                child: Row(
                  children: [
                    Text(entry.value['name']!),
                    SizedBox(width: 10),
                    if (currentLocale == entry.key)
                      Icon(Icons.check, color: AppColors.mainColor, size: 16),
                  ],
                ),
              );
            }).toList();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.notifications,
            color: Colors.white,
            size: screenWidth * 0.065,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> UserNotificationScreen()));
          },
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.white,
            size: screenWidth * 0.065,
          ),
          onPressed: () {
            _showLogoutDialog(context,currentLocale);
          },
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context,final currentLocale) {

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              AppStrings.getString('logout', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              AppStrings.getString('sureToLogout', currentLocale),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(AppStrings.getString('cancel', currentLocale), style: GoogleFonts.poppins()),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mainColor,
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IntroScreen(),
                        ),
                      );
                      await SplashServices.clearUserData();
                    },
                    child: Text(AppStrings.getString('logout', currentLocale), style: GoogleFonts.poppins()),
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
