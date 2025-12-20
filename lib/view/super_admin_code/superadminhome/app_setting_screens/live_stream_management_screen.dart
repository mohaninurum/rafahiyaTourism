import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/super_admin_navbar.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/super_admin_home.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../superadminprovider/live_stream_provider.dart';

class LiveStreamManagementScreen extends StatefulWidget {
  const LiveStreamManagementScreen({super.key});

  @override
  State<LiveStreamManagementScreen> createState() => _LiveStreamManagementScreenState();
}

class _LiveStreamManagementScreenState extends State<LiveStreamManagementScreen> {
  final TextEditingController _makkahController = TextEditingController();
  final TextEditingController _madinahController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final provider = Provider.of<LiveStreamProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('liveStreamManagement', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 20 : 24,
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
        actions: [
          IconButton(
            onPressed: () {
              provider.resetToDefault();
              _makkahController.text = provider.makkahUrl;
              _madinahController.text = provider.madinahUrl;
            },
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            tooltip: AppStrings.getString('resetToDefault', currentLocale),
          ),
        ],
      ),
      body: Consumer<LiveStreamProvider>(
        builder: (context, provider, child) {
          // Initialize controllers with provider values
          if (_makkahController.text.isEmpty && _madinahController.text.isEmpty) {
            _makkahController.text = provider.makkahUrl;
            _madinahController.text = provider.madinahUrl;
          }

          return provider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.mainColor))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(currentLocale),
                const SizedBox(height: 24),
                _buildUrlCard(
                  context,
                  currentLocale,
                  title: AppStrings.getString('makkahLiveStream', currentLocale),
                  subtitle: AppStrings.getString('youtubeUrlMakkah', currentLocale),
                  icon: Icons.mosque,
                  controller: _makkahController,
                ),
                const SizedBox(height: 20),
                _buildUrlCard(
                  context,
                  currentLocale,
                  title: AppStrings.getString('madinahLiveStream', currentLocale),
                  subtitle: AppStrings.getString('youtubeUrlMadinah', currentLocale),
                  icon: Icons.mosque_outlined,
                  controller: _madinahController,
                ),
                const SizedBox(height: 30),
                _buildSaveButton(context, provider, currentLocale),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('manageLiveStreamUrls', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.getString('updateYoutubeUrls', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUrlCard(
      BuildContext context,
      String currentLocale, {
        required String title,
        required String subtitle,
        required IconData icon,
        required TextEditingController controller,
      }) {
    return Card(
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: AppColors.mainColor.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9F5FF),
              Color(0xFFF0EBFF),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: AppStrings.getString('youtubeUrl', currentLocale),
                hintText: 'https://www.youtube.com/watch?v=...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mainColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.mainColor, width: 2),
                ),
                prefixIcon: const Icon(Icons.link, color: AppColors.mainColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getString('youtubeUrlExample', currentLocale),
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, LiveStreamProvider provider, String currentLocale) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          provider.saveUrls(_makkahController.text, _madinahController.text,context);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SuperAdminBottomNavigationBar()));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 5,
        ),
        child: Consumer<LiveStreamProvider>(
          builder: (context, provider, child) {
            return provider.isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text(
              AppStrings.getString('saveChanges', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _makkahController.dispose();
    _madinahController.dispose();
    super.dispose();
  }
}