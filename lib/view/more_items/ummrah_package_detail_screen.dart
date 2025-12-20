import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../utils/model/ummrah_package_model.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class UmrahPackageDetailScreen extends StatelessWidget {
  final UmrahPackage package;

  const UmrahPackageDetailScreen({super.key, required this.package});

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
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(CupertinoIcons.back,
                size: isSmallScreen ? 20 : 24,
                color: Colors.black),
          ),
        ),
        title: Text(
          AppStrings.getString('packageDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: isVerySmallScreen ? 200 : isSmallScreen ? 250 : 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: Image.network(
                      package.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.error, color: Colors.grey[500], size: 50),
                          ),
                    ),
                  ),
                ),
                Container(
                  height: isVerySmallScreen ? 200 : isSmallScreen ? 250 : 300,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: isSmallScreen ? 15 : 20,
                  left: isSmallScreen ? 15 : 20,
                  right: isSmallScreen ? 15 : 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isVerySmallScreen ? 16 : isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                          vertical: isSmallScreen ? 5 : 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          package.duration,
                          style: GoogleFonts.poppins(
                            color: AppColors.mainColor,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.getString('packagePrice', currentLocale),
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "${AppStrings.getString('inr', currentLocale)} ${package.price}",
                              style: GoogleFonts.poppins(
                                fontSize: isSmallScreen ? 18 : 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          package.note,
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.red[400],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 25),

                  if (package.itinerary.isNotEmpty) ...[
                    Text(
                      AppStrings.getString('itineraryOverview', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    Text(
                      package.nightsDetails,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 13 : 15,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 15),
                    ...package.itinerary.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      return _buildItineraryDay(
                          "${AppStrings.getString('day', currentLocale)} ${index + 1}",
                          _formatDate(day.date, currentLocale),
                          day.activities,
                          isSmallScreen,
                          currentLocale
                      );
                    }).toList(),
                    SizedBox(height: isSmallScreen ? 20 : 25),
                  ],

                  if (package.services.isNotEmpty) ...[
                    Text(
                      AppStrings.getString('servicesIncluded', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 15),
                    ...package.services.map((service) =>
                        _buildServiceTile(
                            _getServiceIcon(service.name),
                            service.name,
                            service.description,
                            isSmallScreen
                        )
                    ).toList(),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _launchWhatsApp(context, currentLocale);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: AppColors.mainColor.withOpacity(0.3),
                      ),
                      child: Text(
                        AppStrings.getString('bookNow', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildWhatsAppMessage(UmrahPackage package, String currentLocale) {
    final buffer = StringBuffer();

    buffer.writeln(AppStrings.getString('whatsappGreeting', currentLocale));
    buffer.writeln("");
    buffer.writeln(AppStrings.getString('whatsappInterestMessage', currentLocale));
    buffer.writeln("");
    buffer.writeln(AppStrings.getString('packageInformation', currentLocale));
    buffer.writeln("*${AppStrings.getString('packageName', currentLocale)}:* ${package.title}");
    buffer.writeln("*${AppStrings.getString('price', currentLocale)}:* ${AppStrings.getString('inr', currentLocale)} ${package.price}");
    buffer.writeln("*${AppStrings.getString('duration', currentLocale)}:* ${package.duration}");

    if (package.note.isNotEmpty) {
      buffer.writeln("*${AppStrings.getString('specialNote', currentLocale)}:* ${package.note}");
    }

    buffer.writeln("");
    buffer.writeln(AppStrings.getString('servicesIncluded', currentLocale));

    if (package.services.isNotEmpty) {
      for (final service in package.services.take(5)) {
        buffer.writeln("• ${service.name}");
      }
      if (package.services.length > 5) {
        buffer.writeln("• ${AppStrings.getString('andMoreServices', currentLocale).replaceAll('{count}', (package.services.length - 5).toString())}");
      }
    } else {
      buffer.writeln("• ${AppStrings.getString('comprehensiveServices', currentLocale)}");
    }

    buffer.writeln("");
    buffer.writeln(AppStrings.getString('pleaseProvide', currentLocale));
    buffer.writeln("• ${AppStrings.getString('completePackageDetails', currentLocale)}");
    buffer.writeln("• ${AppStrings.getString('availabilityUpcomingDates', currentLocale)}");
    buffer.writeln("• ${AppStrings.getString('bookingProcedure', currentLocale)}");
    buffer.writeln("• ${AppStrings.getString('currentOffers', currentLocale)}");
    buffer.writeln("");
    buffer.writeln(AppStrings.getString('jazakAllahKhair', currentLocale));

    return buffer.toString();
  }

  void _launchWhatsApp(BuildContext context, String currentLocale) async {
    final phoneNumber = "+919552378468";
    final message = _buildWhatsAppMessage(package, currentLocale);

    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final encodedMessage = Uri.encodeComponent(message);

    final urls = [
      "whatsapp://send?phone=$cleanNumber&text=$encodedMessage",
      "https://wa.me/$cleanNumber?text=$encodedMessage",
      "https://api.whatsapp.com/send?phone=$cleanNumber&text=$encodedMessage",
    ];

    bool launched = false;

    for (final url in urls) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        launched = true;
        break;
      }
    }

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('whatsappNotInstalled', currentLocale)),
        ),
      );
    }
  }

  Widget _buildItineraryDay(String dayNumber, String date, String activities, bool isSmallScreen, String currentLocale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                dayNumber,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    activities,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(IconData icon, String title, String subtitle, bool isSmallScreen) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
      leading: Container(
        width: isSmallScreen ? 40 : 50,
        height: isSmallScreen ? 40 : 50,
        decoration: BoxDecoration(
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
            icon,
            size: isSmallScreen ? 20 : 24,
            color: Colors.white
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: isSmallScreen ? 14 : 16,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle.isNotEmpty ? Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: isSmallScreen ? 12 : 14,
          color: Colors.grey[600],
        ),
      ) : null,
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

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();

    if (name.contains('flight') || name.contains('air')) return Icons.flight;
    if (name.contains('hotel') || name.contains('accommodation')) return Icons.hotel;
    if (name.contains('transfer') || name.contains('transport')) return Icons.directions_bus;
    if (name.contains('meal') || name.contains('food') || name.contains('dining')) return Icons.restaurant;
    if (name.contains('tour') || name.contains('sightseeing')) return Icons.tour;
    if (name.contains('guide') || name.contains('religious')) return Icons.person;
    if (name.contains('visa') || name.contains('document')) return Icons.assignment_ind;
    if (name.contains('laundry')) return Icons.local_laundry_service;
    if (name.contains('kit') || name.contains('ihram')) return Icons.backpack;
    if (name.contains('zamzam') || name.contains('water')) return Icons.water_drop;

    return Icons.check_circle;
  }
}