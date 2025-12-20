import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/utils/services/location_service.dart';
import 'package:rafahiyatourism/view/home/home_screen.dart';
import 'package:rafahiyatourism/view/more_items/more_items_screen.dart';
import 'package:rafahiyatourism/view/wallet/wallet_screen.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';

import '../provider/locale_provider.dart';
import '../utils/widgets/location_permission_dialogue.dart';
import 'more_items/packages_screen.dart';
import 'more_items/sub_items/rafahiya_guide/tutorial_videos_screen.dart';

class BottomNavigation extends StatefulWidget {
  final AuthUserModel? user;
  const BottomNavigation({super.key, this.user});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {

  int _selectedIndex = 0;
  bool _isCheckingLocation = true;
  bool _showLocationDialog = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final locationStatus = await LocationService.checkLocationStatus();

    if (locationStatus != LocationStatus.available) {
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _showLocationDialog = true;
        });
        _showLocationPermissionDialog(locationStatus);
      }
    } else {
      setState(() {
        _isCheckingLocation = false;
      });
    }
  }

  void _showLocationPermissionDialog(LocationStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        locationStatus: status,
        onResult: (success) async {
          if (success) {
            // Location is now available, continue with app
            setState(() {
              _isCheckingLocation = false;
              _showLocationDialog = false;
            });
          } else {
            // User denied or failed to set up location
            setState(() {
              _isCheckingLocation = false;
              _showLocationDialog = false;
            });

            // Show warning message
            final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
            final currentLocale = localeProvider.locale?.languageCode ?? 'en';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.getString('locationWarning', currentLocale),
                  style: GoogleFonts.poppins(),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      ),
    );
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context,listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    if (_isCheckingLocation) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor2,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.mainColor),
              const SizedBox(height: 20),
              Text(
                AppStrings.getString('settingUp', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    List<Widget> screens = [
      HomeScreen(user: widget.user),
      MoreItemsScreen(),
      WalletScreen(user: widget.user),
      TutorialVideosScreen(),
      PackagesScreen(),
    ];

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
          navigationBarButtons:  <NavigationBarButton>[
            NavigationBarButton(
              text: AppStrings.getString('navHome', currentLocale),
              icon: Icons.home_outlined,
              backgroundColor: AppColors.backgroundColor2,
              backgroundGradient: LinearGradient(
                colors: [
                  AppColors.mainColor,
                  AppColors.backgroundColor2,
                  AppColors.backgroundColor3,
                ],
              ),
            ),
            NavigationBarButton(
              text: AppStrings.getString('navMoreItems', currentLocale),
              icon: CupertinoIcons.archivebox_fill,
              backgroundColor: AppColors.backgroundColor2,
              backgroundGradient: LinearGradient(
                colors: [
                  AppColors.mainColor,
                  AppColors.backgroundColor2,
                  AppColors.backgroundColor3,
                ],
              ),
            ),
            NavigationBarButton(
              text: AppStrings.getString('navWallet', currentLocale),
              icon: Icons.wallet,
              backgroundColor: AppColors.backgroundColor2,
              backgroundGradient: LinearGradient(
                colors: [
                  AppColors.mainColor,
                  AppColors.backgroundColor2,
                  AppColors.backgroundColor3,
                ],
              ),
            ),
            NavigationBarButton(
              text: AppStrings.getString('navTutVideos', currentLocale),
              icon: Icons.video_collection_sharp,
              backgroundColor: AppColors.backgroundColor2,
              backgroundGradient: LinearGradient(
                colors: [
                  AppColors.mainColor,
                  AppColors.backgroundColor2,
                  AppColors.backgroundColor3,
                ],
              ),
            ),
            NavigationBarButton(
              text: AppStrings.getString('navPackages', currentLocale),
              icon: Icons.shopping_bag_outlined,
              backgroundColor: AppColors.backgroundColor2,
              backgroundGradient: LinearGradient(
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