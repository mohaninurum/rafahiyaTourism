

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/user_notification_screen.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';
import '../../view/super_admin_code/createuserwallet/user_list_screen.dart';
import '../../view/super_admin_code/notification/super_admin_notification_screen.dart';
import '../../view/super_admin_code/setting/super_admin_setting_screen.dart';
import '../../view/super_admin_code/superadminhome/super_admin_home.dart';


class SuperAdminBottomNavigationBar extends StatefulWidget {
  const SuperAdminBottomNavigationBar({super.key});

  @override
  State<SuperAdminBottomNavigationBar> createState() =>
      _SuperAdminBottomNavigationBarState();
}

class _SuperAdminBottomNavigationBarState extends State<SuperAdminBottomNavigationBar> {
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
    const SuperAdminHome(),
    const UserListScreen(),
    SuperAdminNotificationScreen(currentSuperAdminId: FirebaseAuth.instance.currentUser!.uid,),
    const SuperAdminSettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor2,
        body: screens[_selectedIndex],
        bottomNavigationBar: ResponsiveNavigationBar(
          selectedIndex: _selectedIndex,
          onTabChange: changeTab,
          backgroundColor: AppColors.backgroundColor2,
          inactiveIconColor: AppColors.blackBackground,
          textStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
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
              text: AppStrings.getString('userWallet', currentLocale),
              icon: Icons.wallet,
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
              text: AppStrings.getString('notification', currentLocale),
              icon: Icons.notifications,
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
      ),
    );
  }
}