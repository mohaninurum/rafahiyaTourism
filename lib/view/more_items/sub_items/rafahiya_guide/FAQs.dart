import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../const/color.dart';
import '../../../model/faq_model.dart';
import '../../../super_admin_code/superadminprovider/faq/faq_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../../../provider/locale_provider.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFAQs();
  }

  Future<void> _loadFAQs() async {
    final faqProvider = Provider.of<FAQProvider>(context, listen: false);

    try {
      await faqProvider.loadFAQs();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'loadFailed';
      });
    }
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




  @override
  Widget build(BuildContext context) {
    final faqProvider = Provider.of<FAQProvider>(context);
    final faqs = faqProvider.faqs;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: Text(
          AppStrings.getString('faqs', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState(currentLocale)
          : _errorMessage.isNotEmpty
          ? _buildErrorState(currentLocale)
          : _buildContent(faqs, currentLocale),
    );
  }

  Widget _buildLoadingState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString('loadingFaqs', locale),
            style: GoogleFonts.poppins(
              color: AppColors.mainColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString(_errorMessage, locale),
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _loadFAQs,
            child: Text(
              AppStrings.getString('tryAgain', locale),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<FAQ> faqs, String locale) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, size: 40, color: Colors.white.withOpacity(0.8)),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('faqTitle', locale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // FAQ List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: faqs.map((faq) => _buildFAQItem(faq)).toList(),
            ),
          ),

          // Contact Support Section
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.mainColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  AppStrings.getString('stillHaveQuestions', locale),
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.getString('contactSupportText', locale),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () {
                    _launchWhatsApp(AppStrings.getString('contactSupport', locale));
                  },
                  child: Text(
                    AppStrings.getString('contactSupport', locale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQ faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: GoogleFonts.poppins(
            color: AppColors.mainColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        iconColor: AppColors.mainColor,
        collapsedIconColor: AppColors.mainColor,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
