import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/addForm/admin_addform_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/admin_home_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/profile/admin_profile_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/setting/admin_setting_screen.dart';
import 'package:rafahiyatourism/view/super_admin_code/notification/sub_admin_notifications_screen.dart';
import 'package:rafahiyatourism/view/user_notification_screen.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
import 'package:provider/provider.dart';

import '../../const/color.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class AdminBottomNavigationBar extends StatefulWidget {
  const AdminBottomNavigationBar({super.key});

  @override
  State<AdminBottomNavigationBar> createState() =>
      _AdminBottomNavigationBarState();
}

class _AdminBottomNavigationBarState extends State<AdminBottomNavigationBar> {
  int _selectedIndex = 0;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> screens = [
    SubAdminHomeScreen(),
    AdminProfileScreen(),
    // AdminAddFormScreen(),
    SubAdminNotificationScreen(currentSubAdminId: FirebaseAuth.instance.currentUser!.uid,),
    AdminSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor2,
      body: screens[_selectedIndex],
      bottomNavigationBar: ResponsiveNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: changeTab,
        // showActiveButtonText: false,
        backgroundColor: AppColors.backgroundColor2,
        inactiveIconColor: AppColors.blackBackground,
        textStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        navigationBarButtons: <NavigationBarButton>[
          NavigationBarButton(
            text: AppStrings.getString('home', currentLocale),
            icon: Icons.home_outlined,
            backgroundColor: AppColors.backgroundColor2,
            backgroundGradient: const LinearGradient(
              colors: [
                AppColors.mainColor,
                AppColors.backgroundColor2,
                AppColors.backgroundColor3,
              ],
            ),
          ),
          NavigationBarButton(
            text: AppStrings.getString('profile', currentLocale),
            icon: Icons.person_2_outlined,
            backgroundColor: AppColors.backgroundColor2,
            backgroundGradient: const LinearGradient(
              colors: [
                AppColors.mainColor,
                AppColors.backgroundColor2,
                AppColors.backgroundColor3,
              ],
            ),
          ),
          // NavigationBarButton(
          //   text: AppStrings.getString('addData', currentLocale),
          //   icon: Icons.add_home_outlined,
          //   backgroundColor: AppColors.backgroundColor2,
          //   backgroundGradient: const LinearGradient(
          //     colors: [
          //       AppColors.mainColor,
          //       AppColors.backgroundColor2,
          //       AppColors.backgroundColor3,
          //     ],
          //   ),
          // ),

          NavigationBarButton(
            text: AppStrings.getString('notification', currentLocale),
            icon: Icons.notifications_active,
            backgroundColor: AppColors.backgroundColor2,
            backgroundGradient: const LinearGradient(
              colors: [
                AppColors.mainColor,
                AppColors.backgroundColor2,
                AppColors.backgroundColor3,
              ],
            ),
          ),
          NavigationBarButton(
            text: AppStrings.getString('settings', currentLocale),
            icon: Icons.settings,
            backgroundColor: AppColors.backgroundColor2,
            backgroundGradient: const LinearGradient(
              colors: [
                AppColors.mainColor,
                AppColors.backgroundColor2,
                AppColors.backgroundColor3,
              ],
            ),
          ),
        ],
      ),
    );
  }
}