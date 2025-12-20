import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/view/home/masjid_settings_screen.dart';

import '../../../provider/home_masjid_data_provider.dart';
import '../../../provider/multi_mosque_provider.dart';
import '../../../utils/language/app_strings.dart';
import '../../../utils/services/location_helper.dart';
import '../../../utils/services/location_service.dart';
import '../../../utils/services/map_services.dart';
import '../../../utils/widgets/location_permission_dialogue.dart';

class MasjidInfoHeader extends StatelessWidget {
  final int tabIndex;

  const MasjidInfoHeader({super.key, required this.tabIndex});

  Future<void> _handleDirections(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final canGetLocation = await LocationService.canGetLocation();

    if (!canGetLocation) {
      await _showLocationDialogForDirections(context);
      return;
    }

    await _getDirectionsToMosque(context);
  }

  Future<void> _showLocationDialogForDirections(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onResult: (success) {
          Navigator.of(context).pop(success);
        },
      ),
    );

    if (result == true) {
      await _getDirectionsToMosque(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getString('directionsRequireLocation', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _getDirectionsToMosque(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final multiProvider = Provider.of<MultiMosqueProvider>(context, listen: false);
    final dataProvider = Provider.of<HomeMasjidDataProvider>(context, listen: false);

    final mosqueData = multiProvider.getMosqueData(tabIndex);
    final detailedMosqueData = dataProvider.getMosqueData(tabIndex);

    final mosqueUid = detailedMosqueData?['uid'] ?? mosqueData?['uid'];
    final mosqueName = detailedMosqueData?['name'] ?? mosqueData?['name'] ?? AppStrings.getString('mosque', currentLocale);

    if (mosqueUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('selectMosqueFirst', currentLocale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final location = detailedMosqueData?['location'] ?? mosqueData?['location'];

    if (location == null || location['latitude'] == null || location['longitude'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('locationNotAvailable', currentLocale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double mosqueLat = location['latitude'] is double
        ? location['latitude']
        : double.tryParse(location['latitude'].toString()) ?? 0.0;

    final double mosqueLng = location['longitude'] is double
        ? location['longitude']
        : double.tryParse(location['longitude'].toString()) ?? 0.0;

    if (mosqueLat == 0.0 || mosqueLng == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('invalidLocationCoordinates', currentLocale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(AppStrings.getString('gettingYourLocation', currentLocale)),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );

    try {
      // Get user's current location
      final userLocation = await LocationHelper.getCurrentLocation();

      if (userLocation != null) {
        final double userLat = userLocation['lat']!;
        final double userLng = userLocation['lng']!;

        await MapsService.openDirections(
          userLat: userLat,
          userLng: userLng,
          destinationLat: mosqueLat,
          destinationLng: mosqueLng,
          destinationName: mosqueName,
        );
      } else {
        await MapsService.openDirections(
          destinationLat: mosqueLat,
          destinationLng: mosqueLng,
          destinationName: mosqueName,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('showingMosqueLocation', currentLocale)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('errorOpeningMaps', currentLocale)}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Consumer2<MultiMosqueProvider, HomeMasjidDataProvider>(
      builder: (context, multiProvider, dataProvider, child) {
        final mosqueData = multiProvider.getMosqueData(tabIndex);
        final mosqueUid = mosqueData?['uid'];

        final detailedMosqueData = dataProvider.getMosqueData(tabIndex);


        if (mosqueUid != null && detailedMosqueData == null && !dataProvider.isLoading(tabIndex)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            dataProvider.fetchMosqueData(tabIndex, mosqueUid);
          });
        }

        final mosqueName = detailedMosqueData?['name'] ?? mosqueData?['name'] ?? AppStrings.getString('selectMosque', currentLocale);
        final mosqueAddress = detailedMosqueData?['address'] ?? mosqueData?['address'] ?? AppStrings.getString('tapToAddMosque', currentLocale);
        final mosqueNumber = detailedMosqueData?['masjidPhoneNumber'] ?? AppStrings.getString('notAdded', currentLocale);

        print('Mosque Address $mosqueAddress');


        final location = detailedMosqueData?['location'] ?? mosqueData?['location'];
        final hasLocation = location != null &&
            location['latitude'] != null &&
            location['longitude'] != null;

        return Container(
          width: screenWidth,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF004D26)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Masjid information
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dataProvider.isLoading(tabIndex))
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      Text(
                        mosqueName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 14,
                          letterSpacing: 1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (dataProvider.getError(tabIndex) != null)
                      Text(
                        dataProvider.getError(tabIndex)!,
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: isTablet ? 12 : 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosqueAddress,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 14 : 12,
                            ),
                            maxLines: 2, // Allow 2 lines for address
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    Text(
                      mosqueNumber,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 14 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MasjidSettingsScreen(tabIndex: tabIndex),
                        ),
                      );
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.greyColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.add, color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: hasLocation ? () => _handleDirections(context) : null,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/map.png'),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.directions,
                          color: hasLocation ? AppColors.mainColor : Colors.grey,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}