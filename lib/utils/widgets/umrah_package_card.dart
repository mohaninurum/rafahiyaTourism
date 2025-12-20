import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../const/color.dart';
import '../model/ummrah_package_model.dart';
import 'package:provider/provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class UmrahPackageCard extends StatelessWidget {
  final UmrahPackage package;
  final VoidCallback onViewDetail;

  const UmrahPackageCard({
    super.key,
    required this.package,
    required this.onViewDetail,
  });

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final hasFlights = package.services.any((s) =>
        s.name.toLowerCase().contains('flight'));

    final hasTransfers = package.services.any((s) =>
    s.name.toLowerCase().contains('transfer') ||
        s.name.toLowerCase().contains('transport'));

    final hasHotels = package.services.any((s) =>
    s.name.toLowerCase().contains('hotel') ||
        s.name.toLowerCase().contains('accommodation'));

    final hasTours = package.services.any((s) =>
    s.name.toLowerCase().contains('tour') ||
        s.name.toLowerCase().contains('sightseeing'));

    final hasMeals = package.services.any((s) =>
    s.name.toLowerCase().contains('meal') ||
        s.name.toLowerCase().contains('food') ||
        s.name.toLowerCase().contains('dining'));

    final hasUmrahKit = package.services.any((s) =>
        s.name.toLowerCase().contains('kit'));

    final hasZamZam = package.services.any((s) =>
        s.name.toLowerCase().contains('zam'));

    final hasVisa = package.services.any((s) =>
        s.name.toLowerCase().contains('visa'));

    final hasGuide = package.services.any((s) =>
        s.name.toLowerCase().contains('guide'));

    final hasLaundry = package.services.any((s) =>
        s.name.toLowerCase().contains('laundry'));


    // Get first 3 itinerary days for preview
    final previewItinerary = package.itinerary.take(3).toList();
    final hasMoreItinerary = package.itinerary.length > 3;

    return Container(
      width: screenWidth * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(
                  package.imagePath,
                  height: isSmallScreen ? screenHeight * 0.25 : screenHeight * 0.3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(
                        height: isSmallScreen ? screenHeight * 0.25 : screenHeight * 0.3,
                        color: Colors.grey[300],
                        child: Icon(Icons.error, color: Colors.grey[500]),
                      ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    package.duration,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: isSmallScreen ? 14 : 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.title,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mainColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    package.badge,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: AppColors.whiteBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      package.nightsDetails,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Itinerary Preview Section
          if (package.itinerary.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.getString('itineraryPreview', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...previewItinerary.asMap().entries.map((entry) {
                    final index = entry.key;
                    final day = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.mainColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(day.date, currentLocale),
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  _truncateActivities(day.activities),
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallScreen ? 11 : 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (hasMoreItinerary)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        AppStrings.getString('moreDays', currentLocale).replaceAll('{count}', (package.itinerary.length - 3).toString()),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

          if (hasFlights || hasTransfers || hasHotels || hasTours || hasMeals ||
              hasUmrahKit || hasZamZam || hasVisa || hasGuide || hasLaundry)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(  // ✅ Use Wrap instead of Row for better fitting
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    if (hasFlights) _iconWithLabel(Icons.flight, AppStrings.getString('flights', currentLocale), Colors.blue, isSmallScreen),
                    if (hasTransfers) _iconWithLabel(Icons.directions_bus, AppStrings.getString('transfers', currentLocale), Colors.green, isSmallScreen),
                    if (hasHotels) _iconWithLabel(Icons.king_bed, AppStrings.getString('hotels', currentLocale), Colors.orange, isSmallScreen),
                    if (hasTours) _iconWithLabel(Icons.tour, AppStrings.getString('tours', currentLocale), Colors.purple, isSmallScreen),
                    if (hasMeals) _iconWithLabel(Icons.restaurant, AppStrings.getString('meals', currentLocale), Colors.red, isSmallScreen),
                    if (hasUmrahKit) _iconWithLabel(Icons.backpack, AppStrings.getString('umrahKitSimple', currentLocale), Colors.brown, isSmallScreen),
                    if (hasZamZam) _iconWithLabel(Icons.local_drink, AppStrings.getString('zamZam', currentLocale), Colors.teal, isSmallScreen),
                    if (hasVisa) _iconWithLabel(Icons.verified, AppStrings.getString('visa', currentLocale), Colors.indigo, isSmallScreen),
                    if (hasGuide) _iconWithLabel(Icons.person, AppStrings.getString('guide', currentLocale), Colors.deepPurple, isSmallScreen),
                    if (hasLaundry) _iconWithLabel(Icons.local_laundry_service, AppStrings.getString('laundry', currentLocale), Colors.cyan, isSmallScreen),
                  ],
                ),
              ),
            ),

          const Divider(height: 16, thickness: 1, indent: 16, endIndent: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${AppStrings.getString('inr', currentLocale)} ${package.price}",
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 18 : 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mainColor,
                      ),
                    ),
                    Text(
                      AppStrings.getString('startingFrom', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.note,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 10 : 12,
                        color: Colors.red[400],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(14),
              elevation: 4,
              child: InkWell(
                onTap: onViewDetail,
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.getString('viewDetails', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconWithLabel(IconData icon, String label, Color color, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isSmallScreen ? 18 : 20, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 9 : 10,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, String currentLocale) {
    final monthName = _getMonthName(date.month, currentLocale);
    return '${date.day} $monthName ${date.year}';
  }

  String _getMonthName(int month, String currentLocale) {
    if (currentLocale == 'ar') {
      const arabicMonths = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return arabicMonths[month - 1];
    } else if (currentLocale == 'hi') {
      const hindiMonths = [
        'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
        'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
      ];
      return hindiMonths[month - 1];
    } else {
      const englishMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return englishMonths[month - 1];
    }
  }

  String _truncateActivities(String activities) {
    const maxLength = 60;
    if (activities.length <= maxLength) return activities;
    return '${activities.substring(0, maxLength)}...';
  }
}