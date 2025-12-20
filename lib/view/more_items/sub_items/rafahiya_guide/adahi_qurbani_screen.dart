import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';


class AdahiQurbaniScreen extends StatefulWidget {
  const AdahiQurbaniScreen({super.key});

  @override
  State<AdahiQurbaniScreen> createState() => _AdahiQurbaniScreenState();
}

class _AdahiQurbaniScreenState extends State<AdahiQurbaniScreen> {
  final String phoneNumber = '920020193';
  final String email = 'wecare@adahi.org';
  final String faqsUrl = 'https://www.adahi.org/en/Pages/faqs.aspx';

  String _getCurrentLocale() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _launchTrackingWebsite() async {
    const url = 'https://www.adahi.org/en/pages/TrackOrder.aspx#/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showError(AppStrings.getString('couldNotLaunchWebsite', _getCurrentLocale()));
    }
  }

  Future<void> _launchFAQs() async {
    if (await canLaunchUrl(Uri.parse(faqsUrl))) {
      await launchUrl(Uri.parse(faqsUrl));
    } else {
      _showError(AppStrings.getString('couldNotLaunchFAQs', _getCurrentLocale()));
    }
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      _showError(AppStrings.getString('couldNotLaunchPhone', _getCurrentLocale()));
    }
  }

  Future<void> _sendEmail() async {
    final currentLocale = _getCurrentLocale();
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': AppStrings.getString('adahiQurbaniSupport', currentLocale),
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await Clipboard.setData(ClipboardData(text: email));
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.getString('noEmailAppFound', currentLocale)),
            content: Text(AppStrings.getString('emailCopiedToClipboard', currentLocale)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppStrings.getString('ok', currentLocale)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _showError('${AppStrings.getString('error', currentLocale)}: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    final size = MediaQuery.of(context).size;
    final isSmallDevice = size.width < 350;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(CupertinoIcons.back, color: Colors.white)
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.getString('adahiQurbani', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallDevice ? 18 : 22,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _launchFAQs,
            tooltip: AppStrings.getString('faqs', currentLocale),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Original background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Original gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content with improved layout
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 100),
                      Hero(
                        tag: 'adahi-logo',
                        child: Image.asset(
                          'assets/images/adahi-logo.png',
                          height: isSmallDevice ? 100 : 150,
                          width: isSmallDevice ? 100 : 150,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        AppStrings.getString('adahiQurbaniTracking', currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallDevice ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppStrings.getString('officialQurbaniService', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: isSmallDevice ? 14 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            foregroundColor: Colors.brown[800],
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          onPressed: _launchTrackingWebsite,
                          child: Text(
                            AppStrings.getString('visitTrackingWebsite', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallDevice ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        AppStrings.getString('assistanceContactSupport', currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: isSmallDevice ? 13 : 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ContactButton(
                              icon: Icons.phone,
                              label: AppStrings.getString('call', currentLocale),
                              onPressed: _makePhoneCall,
                              tooltip: phoneNumber,
                              currentLocale: currentLocale,
                            ),
                            _ContactButton(
                              icon: Icons.email,
                              label: AppStrings.getString('email', currentLocale),
                              onPressed: _sendEmail,
                              tooltip: email,
                              currentLocale: currentLocale,
                            ),
                            _ContactButton(
                              icon: Icons.help,
                              label: AppStrings.getString('faqs', currentLocale),
                              onPressed: _launchFAQs,
                              tooltip: AppStrings.getString('frequentlyAskedQuestions', currentLocale),
                              currentLocale: currentLocale,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final String tooltip;
  final String currentLocale;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.tooltip,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
            iconSize: 28,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}