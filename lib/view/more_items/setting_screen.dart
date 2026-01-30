import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../provider/setting_provider.dart';
import '../../utils/language/app_strings.dart';
import '../../utils/services/splash_services.dart';
import '../auth/intro_slider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _mosqueOffsetAnimation;

  bool salah = false;
  bool bayan = false;
  bool clockNotification = false;

  int newValue = 1;

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
    fetchSetting();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeLanguage(String languageCode) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(languageCode);
  }

  void fetchSetting(){
    Provider.of<SettingProvider>(context,listen: false).fetchSetting();
  }


  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final settingProvider = Provider.of<SettingProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

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
                padding: const EdgeInsets.only(top: 50.0, left: 20),
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Colors.white54,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(CupertinoIcons.back,
                        color: AppColors.whiteColor, size: 25),
                  ),
                ),
              ),

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
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    AppStrings.getString('notificationSettings', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Consumer<SettingProvider>(builder: (context, value, child) {
                return    Container(
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
                      SwitchListTile(
                        activeColor: AppColors.mainColor,
                        title: SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('salahUpdate', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                        value: value.sahahUpdate,
                        onChanged: (bool value) {
                          setState(() {
                            salah = value;
                          });
                          settingProvider.updateNotificationSetting(
                            key: 'sahahUpdate',
                            value: value,
                          );

                        },
                        secondary: const Icon(
                          Icons.mosque_outlined,
                          color: AppColors.mainColor,
                        ),
                      ),
                      SwitchListTile(
                        activeColor: AppColors.mainColor,
                        title: SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('bayanAlerts', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                        value: value.banyanAlerts,
                        onChanged: (bool value) {
                          setState(() {
                            bayan = value;
                          });
                          settingProvider.updateNotificationSetting(
                            key: 'banyanAlerts',
                            value: value,
                          );

                        },
                        secondary: const Icon(
                          Icons.record_voice_over_outlined,
                          color: AppColors.mainColor,
                        ),
                      ),
                      SwitchListTile(
                        activeColor: AppColors.mainColor,
                        title: SlideTransition(
                          position: _mosqueOffsetAnimation,
                          child: Text(
                            AppStrings.getString('clockChangeNotification', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                        value: value.clockChangeNotification,
                        onChanged: (bool value) {
                          setState(() {
                            clockNotification = value;
                          });
                          settingProvider.updateNotificationSetting(
                            key: 'clock_change_notification',
                            value: value,
                          );

                        },
                        secondary: const Icon(
                          Icons.notifications_on,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                );
              },),

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
                          groupValue: newValue,
                          onChanged: (value) {
                            setState(() {
                              newValue = value!;
                            });
                            _changeLanguage('en');
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
                          groupValue: newValue,
                          onChanged: (value) {
                            setState(() {
                              newValue = value!;
                            });
                            _changeLanguage('ar');
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
                          groupValue: newValue,
                          onChanged: (value) {
                            setState(() {
                              newValue = value!;
                            });
                            _changeLanguage('hi');
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
                  height: 60,
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
                    children: [
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
                        onTap: (){
                          _showLogoutDialog(context,currentLocale);
                        },
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