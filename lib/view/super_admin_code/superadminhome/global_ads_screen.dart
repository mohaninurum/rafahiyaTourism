import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/models/global_ads_model/global_ad.dart';
import '../../../const/color.dart';
import '../../../provider/ads_provider.dart';

class GlobalAdsScreen extends StatefulWidget {
  const GlobalAdsScreen({super.key});

  @override
  State<GlobalAdsScreen> createState() => _GlobalAdsScreenState();
}

class _GlobalAdsScreenState extends State<GlobalAdsScreen> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AdsProvider>(context, listen: false);
      provider.initialize();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          AppStrings.getString('globalAdsManagement', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => Provider.of<AdsProvider>(context, listen: false)
                .showCountrySelectionDialog(context),
          ),
        ],
      ),
      body: Consumer<AdsProvider>(
        builder: (context, adsProvider, child) {
          print('Consumer rebuild - isLoading: ${adsProvider.isLoading}, ads count: ${adsProvider.ads.length}');

          if (adsProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SpinKitChasingDots(
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.getString('loading', currentLocale),
                    style: GoogleFonts.nunito(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          return adsProvider.ads.isEmpty
              ? _buildEmptyState(currentLocale)
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adsProvider.ads.length,
            itemBuilder: (context, index) {
              final ad = adsProvider.ads[index];
              return _buildAdCard(context, ad, currentLocale);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdCard(BuildContext context, GlobalAdModel ad, String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: (ad.imageUrl != null && ad.imageUrl!.trim().isNotEmpty && Uri.tryParse(ad.imageUrl!)?.hasAbsolutePath == true)
                ? Image.network(
              ad.imageUrl!,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/images/logo.png',
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ad.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: ad.isActive,
                      onChanged: (value) =>
                          Provider.of<AdsProvider>(context, listen: false)
                              .toggleAdStatus(ad.id),
                      activeColor: AppColors.mainColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ad.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (ad.link != null && ad.link!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      if (Uri.tryParse(ad.link!) != null) {
                        // You might want to launch the URL here
                        // using url_launcher package
                      }
                    },
                    child: Text(
                      '${AppStrings.getString('link', currentLocale)}: ${ad.link}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildDateChip('${AppStrings.getString('start', currentLocale)}: ${ad.startDate}', currentLocale),
                    const SizedBox(width: 8),
                    _buildDateChip('${AppStrings.getString('end', currentLocale)}: ${ad.endDate}', currentLocale),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildLocationChip('${AppStrings.getString('country', currentLocale)}: ${ad.country}', currentLocale),
                    const SizedBox(width: 8),
                    _buildLocationChip('${AppStrings.getString('city', currentLocale)}: ${ad.city}', currentLocale),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Provider.of<AdsProvider>(context, listen: false)
                          .showEditAdBottomSheet(context, ad),
                      child: Text(
                        AppStrings.getString('edit', currentLocale).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Provider.of<AdsProvider>(context, listen: false)
                          .confirmDeleteAd(context, ad.id),
                      child: Text(
                        AppStrings.getString('delete', currentLocale).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip(String text, String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildDateChip(String text, String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ads_click,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString('noGlobalAdsCreated', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('tapToCreateFirstAd', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}