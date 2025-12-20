
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../const/color.dart';
import '../../admin_side_code/data/subAdminProvider/admin_login_provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class SuperAdminSettingScreen extends StatefulWidget {
  const SuperAdminSettingScreen({super.key});

  @override
  State<SuperAdminSettingScreen> createState() =>
      _SuperAdminSettingScreenState();
}

class _SuperAdminSettingScreenState extends State<SuperAdminSettingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _mosqueOffsetAnimation;

  bool enableNotifications = true;
  bool darkMode = false;
  bool biometricLogin = true;

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

  void _handleLogout(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdminsLoginProvider>(context, listen: false);
      provider.signOut(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.white,
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
                          AppStrings.getString('settings', currentLocale).toUpperCase(),
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

              _buildSectionHeader(AppStrings.getString('notificationSettings', currentLocale), currentLocale),
              _buildSettingsContainer([
                _buildSwitchTile(
                  icon: Icons.notifications,
                  title: AppStrings.getString('enableNotifications', currentLocale),
                  value: enableNotifications,
                  onChanged: (val) => setState(() => enableNotifications = val),
                  currentLocale: currentLocale,
                ),
              ], currentLocale),

              _buildSectionHeader(AppStrings.getString('appLanguage', currentLocale), currentLocale),
              _buildSettingsContainer([
                _buildListTile(
                  icon: Icons.language,
                  title: AppStrings.getString('appLanguage', currentLocale),
                  subtitle: localeProvider.getCurrentLanguageName(),
                  onTap: () => _showLanguageDialog(context, currentLocale, localeProvider),
                  currentLocale: currentLocale,
                ),
              ], currentLocale),


              _buildSectionHeader(AppStrings.getString('logout', currentLocale), currentLocale),
              _buildSettingsContainer([
                _buildListTile(
                  icon: Icons.exit_to_app,
                  title: AppStrings.getString('logOut', currentLocale),
                  subtitle: AppStrings.getString('signOutAccount', currentLocale),
                  isImportant: true,
                  onTap: () => _handleLogout(context),
                  currentLocale: currentLocale,
                ),
              ], currentLocale),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(final currentLocale) async {


    final phoneNumber = '+919552378468';
    final url = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw '${AppStrings.getString('couldNotLaunch', currentLocale)} $url';
      }
    } catch (e) {
      print('${AppStrings.getString('errorLaunchingWhatsApp', currentLocale)}: $e');
    }
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider, String currentLocale) {
    return SlideTransition(
      position: _mosqueOffsetAnimation,
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.language,
            color: AppColors.mainColor,
            size: 24,
          ),
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
                  const SizedBox(width: 10),
                  if (currentLocale == entry.key)
                    Icon(Icons.check, color: AppColors.mainColor, size: 16),
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String currentLocale) {
    return SlideTransition(
      position: _mosqueOffsetAnimation,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 20),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.blackBackground,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children, String currentLocale) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Divider(height: 1, color: Colors.grey.shade200),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required String currentLocale,
  }) {
    return SwitchListTile(
      activeColor: AppColors.mainColor,
      title: SlideTransition(
        position: _mosqueOffsetAnimation,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackBackground,
          ),
        ),
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon, color: AppColors.mainColor),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
    bool isImportant = false,
    bool showTrailing = true,
    required String currentLocale,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isImportant ? Colors.red : AppColors.mainColor,
      ),
      title: SlideTransition(
        position: _mosqueOffsetAnimation,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isImportant ? Colors.red : AppColors.blackBackground,
          ),
        ),
      ),
      subtitle: SlideTransition(
        position: _mosqueOffsetAnimation,
        child: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
      trailing: showTrailing
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLocale, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('selectLanguage', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: Text(
                  AppStrings.getString('english', currentLocale),
                  style: GoogleFonts.poppins(),
                ),
                value: 'en',
                groupValue: currentLocale,
                onChanged: (value) {
                  localeProvider.setLocale(value.toString());
                  Navigator.pop(context);
                },
                activeColor: AppColors.mainColor,
              ),
              RadioListTile(
                title: Text(
                  AppStrings.getString('arabic', currentLocale),
                  style: GoogleFonts.poppins(),
                ),
                value: 'ar',
                groupValue: currentLocale,
                onChanged: (value) {
                  localeProvider.setLocale(value.toString());
                  Navigator.pop(context);
                },
                activeColor: AppColors.mainColor,
              ),
              RadioListTile(
                title: Text(
                  AppStrings.getString('hindi', currentLocale),
                  style: GoogleFonts.poppins(),
                ),
                value: 'hi',
                groupValue: currentLocale,
                onChanged: (value) {
                  localeProvider.setLocale(value.toString());
                  Navigator.pop(context);
                },
                activeColor: AppColors.mainColor,
              ),
            ],
          ),
        );
      },
    );
  }
}