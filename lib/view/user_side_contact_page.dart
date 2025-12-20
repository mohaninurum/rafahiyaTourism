import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';

import '../utils/language/app_strings.dart';

class UserContactPage extends StatefulWidget {
  const UserContactPage({super.key});

  @override
  State<UserContactPage> createState() => _UserContactPageState();
}

class _UserContactPageState extends State<UserContactPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContactInfo();
  }

  Future<void> _loadContactInfo() async {
    await Provider.of<AppSettingsProvider>(context, listen: false).fetchContactInfo();
    setState(() => _isLoading = false);
  }

  void _launchURL(String url, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('couldNotOpen', currentLocale)} $url'),
        ),
      );
    }
  }

  void _launchPhone(String phone, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (phone.isEmpty) return;

    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('couldNotCall', currentLocale)} $phone'),
        ),
      );
    }
  }

  void _launchEmail(String email, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (email.isEmpty) return;

    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('couldNotEmail', currentLocale)} $email'),
        ),
      );
    }
  }

  void _launchWhatsApp(String whatsapp, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (whatsapp.isEmpty) return;

    // Clean the number (remove any non-digit characters except +)
    final cleanedNumber = whatsapp.replaceAll(RegExp(r'[^\d+]'), '');
    final String url = "https://wa.me/$cleanedNumber";
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('couldNotOpenWhatsApp', currentLocale)),
        ),
      );
    }
  }

  void _launchMap(String address, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (address.isEmpty) return;

    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$address');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('couldNotOpenMaps', currentLocale)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppSettingsProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppStrings.getString('contactUs', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.mainColor))
          : _buildContent(provider, isSmallScreen, currentLocale),
    );
  }

  Widget _buildContent(AppSettingsProvider provider, bool isSmallScreen, String currentLocale) {
    final hasAnyContactInfo =
        provider.contactPhone.isNotEmpty ||
            provider.contactEmail.isNotEmpty ||
            provider.contactAddress.isNotEmpty ||
            provider.contactWebsite.isNotEmpty ||
            provider.contactWhatsApp.isNotEmpty ||
            provider.contactFacebook.isNotEmpty ||
            provider.contactInstagram.isNotEmpty ||
            provider.contactTwitter.isNotEmpty;

    if (!hasAnyContactInfo) {
      return _buildNoContactInfo(currentLocale);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(currentLocale),
          const SizedBox(height: 24),

          // Contact Methods
          if (provider.contactPhone.isNotEmpty)
            _buildContactMethod(
              icon: Icons.phone,
              title: AppStrings.getString('callUs', currentLocale),
              value: provider.contactPhone,
              onTap: () => _launchPhone(provider.contactPhone, context),
              color: Colors.blue,
              currentLocale: currentLocale,
            ),

          if (provider.contactWhatsApp.isNotEmpty)
            _buildContactMethod(
              icon: FontAwesomeIcons.whatsapp,
              title: AppStrings.getString('whatsapp', currentLocale),
              value: provider.contactWhatsApp,
              onTap: () => _launchWhatsApp(provider.contactWhatsApp, context),
              color: Colors.green,
              currentLocale: currentLocale,
            ),

          if (provider.contactEmail.isNotEmpty)
            _buildContactMethod(
              icon: Icons.email,
              title: AppStrings.getString('emailUs', currentLocale),
              value: provider.contactEmail,
              onTap: () => _launchEmail(provider.contactEmail, context),
              color: Colors.red,
              currentLocale: currentLocale,
            ),

          if (provider.contactAddress.isNotEmpty)
            _buildContactMethod(
              icon: Icons.location_on,
              title: AppStrings.getString('visitUs', currentLocale),
              value: provider.contactAddress,
              onTap: () => _launchMap(provider.contactAddress, context),
              color: Colors.orange,
              currentLocale: currentLocale,
            ),

          if (provider.contactWebsite.isNotEmpty)
            _buildContactMethod(
              icon: Icons.language,
              title: AppStrings.getString('website', currentLocale),
              value: provider.contactWebsite,
              onTap: () => _launchURL(provider.contactWebsite, context),
              color: Colors.purple,
              currentLocale: currentLocale,
            ),

          // Social Media Section (if any social media exists)
          if (provider.contactFacebook.isNotEmpty ||
              provider.contactInstagram.isNotEmpty ||
              provider.contactTwitter.isNotEmpty)
            _buildSocialMediaSection(provider, currentLocale),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader(String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('getInTouch', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getString('contactDescription', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
    required String currentLocale,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(AppSettingsProvider provider, String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          AppStrings.getString('followUs', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getString('socialMediaDescription', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (provider.contactFacebook.isNotEmpty)
              _buildSocialMediaIcon(
                icon: FontAwesomeIcons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () => _launchURL(provider.contactFacebook, context),
              ),

            if (provider.contactInstagram.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildSocialMediaIcon(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE4405F),
                  onTap: () => _launchURL(provider.contactInstagram, context),
                ),
              ),

            if (provider.contactTwitter.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildSocialMediaIcon(
                  icon: FontAwesomeIcons.twitter,
                  color: const Color(0xFF1DA1F2),
                  onTap: () => _launchURL(provider.contactTwitter, context),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSocialMediaIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildNoContactInfo(String currentLocale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contact_phone_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.getString('contactInfoNotAvailable', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('checkBackLater', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}