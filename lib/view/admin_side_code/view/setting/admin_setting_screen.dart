import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/utils/circular_indicator_spinkit.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_login_provider.dart';
import 'package:rafahiyatourism/view/user_notification_screen.dart';

import '../../../auth/intro_slider.dart';

class AdminSettingScreen extends StatefulWidget {
  const AdminSettingScreen({super.key});

  @override
  State<AdminSettingScreen> createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _mosqueOffsetAnimation;

  bool _isLoggingOut = false;

  // Map radio values to language codes
  final Map<int, String> _languageMap = {
    1: 'en', // English
    2: 'ar', // Arabic
    3: 'hi', // Hindi
  };

  // Map language codes to radio values
  final Map<String, int> _reverseLanguageMap = {
    'en': 1,
    'ar': 2,
    'hi': 3,
  };

  int _getInitialRadioValue(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    return _reverseLanguageMap[currentLocale] ?? 1;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _mosqueOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final currentLocale = _getCurrentLocale(context);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('logout', currentLocale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor,
            ),
          ),
          content: Text(
            AppStrings.getString('confirmLogoutMessage', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: AppColors.mainColor),
              ),
            ),
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                setState(() => _isLoggingOut = true);
                Navigator.of(context).pop(true);
                await _performLogout(context, currentLocale);
                setState(() => _isLoggingOut = false);
              },
              child: _isLoggingOut
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CustomCircularProgressIndicator(
                  size: 20.0,
                  color: AppColors.mainColor,
                ),
              )
                  : Text(
                AppStrings.getString('logout', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context, String currentLocale) async {
    try {
      final provider = Provider.of<AdminsLoginProvider>(context, listen: false);
      await provider.signOut(context);

      // Navigate to intro screen after logout
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
            (route) => false,
      );
    } catch (e) {
      // Handle any errors during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('logoutFailed', currentLocale)}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _changeLanguage(int value, BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languageCode = _languageMap[value];

    if (languageCode != null) {
      // Update the locale provider
      localeProvider.setLocale(languageCode);

      // Update UI state
      setState(() {
        // The radio button value will be updated automatically through the provider
      });
    }
  }

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentRadioValue = _reverseLanguageMap[localeProvider.locale?.languageCode ?? 'en'] ?? 1;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/container_image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    SlideTransition(
                      position: _mosqueOffsetAnimation,
                      child: Center(
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/images/masjid.png"),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SlideTransition(
                      position: _mosqueOffsetAnimation,
                      child: Center(
                        child: Text(
                          AppStrings.getString('settings', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackBackground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    AppStrings.getString('languagePreferences', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.whiteBackground,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Radio(
                          activeColor: AppColors.mainColor,
                          value: 1,
                          groupValue: currentRadioValue,
                          onChanged: (value) {
                            _changeLanguage(value!, context);
                          },
                        ),
                        const SizedBox(width: 10.0),
                        SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('english', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: AppColors.mainColor,
                          value: 2,
                          groupValue: currentRadioValue,
                          onChanged: (value) {
                            _changeLanguage(value!, context);
                          },
                        ),
                        const SizedBox(width: 10.0),
                        SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('arabic', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          activeColor: AppColors.mainColor,
                          value: 3,
                          groupValue: currentRadioValue,
                          onChanged: (value) {
                            _changeLanguage(value!, context);
                          },
                        ),
                        const SizedBox(width: 10.0),
                        SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('hindi', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    AppStrings.getString('generalSettings', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: AppColors.whiteBackground,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ListTile(
                      //   leading: Icon(
                      //     CupertinoIcons.bell_circle_fill,
                      //     color: AppColors.mainColor,
                      //   ),
                      //   title: Text(
                      //     AppStrings.getString('notification', currentLocale),
                      //     style: GoogleFonts.poppins(
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w500,
                      //       color: AppColors.blackBackground,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(context, MaterialPageRoute(builder: (context)=> UserNotificationScreen()));
                      //   },
                      // ),
                      ListTile(
                        leading: Icon(
                          CupertinoIcons.lock_shield,
                          color: AppColors.mainColor,
                        ),
                        title: Text(
                          AppStrings.getString('logout', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackBackground,
                          ),
                        ),
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}