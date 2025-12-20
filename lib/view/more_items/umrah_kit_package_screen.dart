import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/view/more_items/ummrah_package_detail_screen.dart';

import '../../provider/add_umrah_packages_provider.dart';
import '../../utils/model/ummrah_package_model.dart';
import '../../utils/widgets/umrah_package_card.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class UmrahKitPackageScreen extends StatefulWidget {
  const UmrahKitPackageScreen({super.key});

  @override
  State<UmrahKitPackageScreen> createState() => _UmrahKitPackageScreenState();
}

class _UmrahKitPackageScreenState extends State<UmrahKitPackageScreen> {
  bool _isLoading = true;

  String _getCurrentLocale() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPackages();
    });
  }

  Future<void> _loadPackages() async {
    final currentLocale = _getCurrentLocale();
    try {
      await Provider.of<AddUmrahPackageProvider>(context, listen: false)
          .fetchPackages();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading packages: $e');
      setState(() {
        _isLoading = false;
      });
      // Show error message if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('failedToLoadPackages', currentLocale)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final packageProvider = Provider.of<AddUmrahPackageProvider>(context);
    final packages = packageProvider.packages;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        title: Text(
          AppStrings.getString('umrahPackages', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
        child: SpinKitChasingDots(
          color: AppColors.mainColor,
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              AppStrings.getString('discoverSacredJourneys', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: AppColors.mainColor,
              ),
            ),
          ),
          Expanded(
            child: packages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('noPackagesAvailable', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('checkBackLaterPackages', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: packages.length,
              itemBuilder: (context, index) {
                final package = packages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: UmrahPackageCard(
                    package: UmrahPackage(
                      // Convert AddUmrahPackage to UmrahPackage for the card
                      id: package.id,
                      imagePath: package.imageUrl,
                      title: package.title,
                      duration: package.durationString,
                      badge: AppStrings.getString('allInclusivePackage', currentLocale),
                      nightsDetails:
                      '${package.durationInDays} ${AppStrings.getString('days', currentLocale)}',
                      price: package.price,
                      note: package.note,
                      startDate: package.startDate,
                      endDate: package.endDate,
                      itinerary: package.itinerary,
                      services: package.services,
                    ),
                    onViewDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UmrahPackageDetailScreen(
                              package: UmrahPackage(
                                // Convert for detail screen too
                                id: package.id,
                                imagePath: package.imageUrl,
                                title: package.title,
                                duration: package.durationString,
                                badge: AppStrings.getString('allInclusivePackage', currentLocale),
                                nightsDetails:
                                '${package.durationInDays} ${AppStrings.getString('days', currentLocale)}',
                                price: package.price,
                                note: package.note,
                                startDate: package.startDate,
                                endDate: package.endDate,
                                itinerary: package.itinerary,
                                services: package.services,
                              )),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}