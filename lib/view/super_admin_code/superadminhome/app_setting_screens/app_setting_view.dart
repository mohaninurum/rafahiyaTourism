import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/app_setting_screens/terms_condition_screen.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import 'about_pdf_screen.dart';
import 'contact_rafhiya_tourism.dart';
import 'edit_intro_page.dart';
import 'faq_management_screen.dart';
import 'home_slider_image_management.dart';
import 'live_stream_management_screen.dart';
import 'marquee_text_management_screen.dart';

class AppSettingView extends StatefulWidget {
  const AppSettingView({super.key});

  @override
  State<AppSettingView> createState() => _AppSettingViewState();
}

class _AppSettingViewState extends State<AppSettingView> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600 && screenWidth < 900;
    final isExtraLargeScreen = screenWidth >= 900;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('appSettings', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: isExtraLargeScreen
                ? 32
                : isLargeScreen
                ? 28
                : isMediumScreen
                ? 24
                : 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 16 : isMediumScreen ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.info_outline_rounded,
                      title: AppStrings.getString('infoPage', currentLocale),
                      subtitle: AppStrings.getString('editAppInfo', currentLocale),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const IntroEditScreen()));
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.description_outlined,
                      title: AppStrings.getString('termsAndConditions', currentLocale),
                      subtitle: AppStrings.getString('updateTerms', currentLocale),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const TermsConditionsScreen()));
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.business_center_outlined,
                      title: AppStrings.getString('aboutCompany', currentLocale),
                      subtitle: AppStrings.getString('editCompanyInfo', currentLocale),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> const ManageAboutPdfScreen()));
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.contact_phone_outlined,
                      title: AppStrings.getString('contactRafahiyahTourism', currentLocale),
                      subtitle: AppStrings.getString('updateContactInfo', currentLocale),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const ContactManagementScreen()
                        ));
                      },
                    ),
                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.slideshow_rounded,
                      title: AppStrings.getString('homeSliderImages', currentLocale),
                      subtitle: AppStrings.getString('updateAdsImages', currentLocale),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const HomeSliderManagementScreen()
                        ));
                      },
                    ),
                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.help_outline,
                      title: AppStrings.getString('faqsManagement', currentLocale),
                      subtitle: AppStrings.getString('manageAppFaqs', currentLocale),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FAQsManagementScreen()),
                        );
                      },
                    ),
                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.live_tv,
                      title: AppStrings.getString('liveStreamUrls', currentLocale),
                      subtitle: AppStrings.getString('manageMakkahMadinahUrls', currentLocale),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LiveStreamManagementScreen()),
                        );
                      },
                    ),
                    _buildSettingCard(
                      context,
                      currentLocale,
                      icon: Icons.text_rotation_none_sharp,
                      title: AppStrings.getString('marqueeTextManagement', currentLocale),
                      subtitle: AppStrings.getString('updateScrollingText', currentLocale),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MarqueeTextManagementScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
      BuildContext context,
      String currentLocale, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFF5F9FF),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: isSmallScreen ? 50 : 60,
                height: isSmallScreen ? 50 : 60,
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.mainColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}