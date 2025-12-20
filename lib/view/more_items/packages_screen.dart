import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/more_items/ummrah_package_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../const/color.dart';
import '../../provider/add_umrah_packages_provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';
import '../../utils/model/ummrah_package_model.dart';
import '../../utils/widgets/umrah_package_card.dart';

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPackages();
    });
  }

  Future<void> _loadPackages() async {
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
          content: Text('Failed to load packages'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final packageProvider = Provider.of<AddUmrahPackageProvider>(context);
    final packages = packageProvider.packages;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';


    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          size: 50.0,
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
              child: Text(
                AppStrings.getString('noPackagesAvailable', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                ),
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
                                id: package.id,
                                imagePath: package.imageUrl,
                                title: package.title,
                                duration: package.durationString,
                                badge: AppStrings.getString('allInclusivePackage', currentLocale),
                                nightsDetails:  '${package.durationInDays} ${AppStrings.getString('days', currentLocale)}',
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