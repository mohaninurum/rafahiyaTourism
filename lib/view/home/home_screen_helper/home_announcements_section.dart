
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/view/home/bank_detail_screen.dart';

import '../../../provider/home_masjid_data_provider.dart';
import '../../../utils/language/app_strings.dart';
import 'bayan_detail_screen.dart';

class AnnouncementsSection extends StatelessWidget {
  final int tabIndex;
  final HomeMasjidDataProvider dataProvider;

  const AnnouncementsSection({
    super.key,
    required this.tabIndex,
    required this.dataProvider,
  });

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final hadiyaDetailsList = dataProvider.getHadiyaDetails(tabIndex);
    final bayanDataList = dataProvider.getBayanData(tabIndex);
    final masjidHadiyas = hadiyaDetailsList?.where((hadiya) => hadiya['type'] == 'Masjid').toList() ?? [];
    final maulanaHadiyas = hadiyaDetailsList?.where((hadiya) => hadiya['type'] == 'Maulana').toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: ExpansionTile(
            backgroundColor: AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            title: Text(
              AppStrings.getString('hadiya', currentLocale),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.white),
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8,
            ),
            children: [
              // Display Maulana Hadiyas
              if (maulanaHadiyas.isNotEmpty)
                ...maulanaHadiyas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hadiya = entry.value;
                  return Column(
                    children: [
                      if (index > 0) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Divider(thickness: 0.5, color: AppColors.blackColor),
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildAnnouncementItem(
                        title: "${AppStrings.getString('hadiyaForMaulana', currentLocale)}${maulanaHadiyas.length > 1 ? ' ${index + 1}' : ''}",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BankDetailsScreen(
                                hadiyaDetails: hadiya,
                                type: 'Maulana',
                              ),
                            ),
                          );
                        },
                        currentLocale: currentLocale,
                      ),
                    ],
                  );
                }).toList(),

              // Add divider between Maulana and Masjid hadiyas if both exist
              if (maulanaHadiyas.isNotEmpty && masjidHadiyas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Divider(thickness: 0.5, color: AppColors.blackColor),
                ),
                const SizedBox(height: 10),
              ],

              // Display Masjid Hadiyas
              if (masjidHadiyas.isNotEmpty)
                ...masjidHadiyas.asMap().entries.map((entry) {
                  final index = entry.key;
                  final hadiya = entry.value;
                  return Column(
                    children: [
                      if (index > 0) ...[
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Divider(thickness: 0.5, color: AppColors.blackColor),
                        ),
                        const SizedBox(height: 10),
                      ],
                      _buildAnnouncementItem(
                        title: "${AppStrings.getString('hadiyaForMasjid', currentLocale)}${masjidHadiyas.length > 1 ? ' ${index + 1}' : ''}",
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BankDetailsScreen(
                                hadiyaDetails: hadiya,
                                type: 'Masjid',
                              ),
                            ),
                          );
                        },
                        currentLocale: currentLocale,
                      ),
                    ],
                  );
                }).toList(),

              if (maulanaHadiyas.isEmpty && masjidHadiyas.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                    AppStrings.getString('noHadiyaDetails', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: AppColors.mainColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            backgroundColor: AppColors.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            title: Text(
              AppStrings.getString('masjidAnnouncements', currentLocale),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.white),
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 8,
            ),
            children: [
              if (bayanDataList != null && bayanDataList.isNotEmpty)
                ...bayanDataList.map((bayanData) {
                  return _buildBayanCard(context, bayanData, currentLocale);
                }).toList()
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
                  child: Text(
                    AppStrings.getString('noAnnouncements', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBayanCard(BuildContext context, Map<String, dynamic> bayanData, String currentLocale) {
    final title = bayanData['title'] ?? AppStrings.getString('noTitle', currentLocale);
    final imageUrl = bayanData['imageUrl'];

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BayanDetailScreen(
                bayanData: bayanData,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image
              if (imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mainColor,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.campaign_outlined,
                    color: AppColors.mainColor,
                  ),
                ),

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required String title,
    required VoidCallback onPressed,
    required String currentLocale,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.blackBackground,
            ),
          ),
          InkWell(
            onTap: onPressed,
            child: Row(
              children: [
                Text(
                  AppStrings.getString('clickHere', currentLocale),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12
                  ),
                ),
                Icon(Icons.arrow_forward_ios_outlined, color: AppColors.mainColor, size: 12,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}