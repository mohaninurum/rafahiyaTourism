import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class NuzukAppScreen extends StatefulWidget {
  const NuzukAppScreen({super.key});

  @override
  State<NuzukAppScreen> createState() => _NuzukAppScreenState();
}

class _NuzukAppScreenState extends State<NuzukAppScreen> {
  bool _isAppInstalled = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _checkIfAppInstalled() async {
    try {
      bool canLaunch = await canLaunchUrl(Uri.parse('nusukapp://'));
      setState(() {
        _isAppInstalled = canLaunch;
      });
    } catch (e) {
      setState(() {
        _isAppInstalled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkIfAppInstalled();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      height: 100,
                      width: 100,
                    ),

                    const SizedBox(height: 10),
                    Text(
                      AppStrings.getString('officialSaudiPilgrimageGuide', currentLocale),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                SizedBox(
                  height: size.height * 0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _FeatureCard(
                        icon: Icons.mosque,
                        title: AppStrings.getString('hajjUmrah', currentLocale),
                        color: Colors.amber[700]!,
                        currentLocale: currentLocale,
                      ),
                      _FeatureCard(
                        icon: Icons.map,
                        title: AppStrings.getString('holySites', currentLocale),
                        color: Colors.green[700]!,
                        currentLocale: currentLocale,
                      ),
                      _FeatureCard(
                        icon: Icons.assistant,
                        title: AppStrings.getString('guidance', currentLocale),
                        color: Colors.blue[700]!,
                        currentLocale: currentLocale,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _launchURL('https://www.nusuk.sa/'),
                        child: Text(
                          AppStrings.getString('visitNusukWebsite', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_isAppInstalled) {
                            try {
                              await _launchURL('nusukapp://open');
                            } catch (e) {
                              await _launchURL('https://play.google.com/store/apps/details?id=com.moh.nusukapp&hl=en');
                            }
                          } else {
                            await _launchURL('https://play.google.com/store/apps/details?id=com.moh.nusukapp&hl=en');
                          }
                        },
                        child: Text(
                          _isAppInstalled
                              ? AppStrings.getString('openNusukApp', currentLocale)
                              : AppStrings.getString('getNusukApp', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String currentLocale;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}