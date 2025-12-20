import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  double _qiblaDirection = 0.0;
  bool _isLoading = true;
  String _errorMessage = '';

  // Kaaba coordinates in Mecca
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final currentLocale = _getCurrentLocale(context);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppStrings.getString('locationServiceDisabled', currentLocale);
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever ||
            permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _errorMessage = AppStrings.getString('locationPermissionDenied', currentLocale);
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Calculate Qibla direction locally
      _calculateQiblaDirection(position.latitude, position.longitude);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${AppStrings.getString('errorGettingLocation', currentLocale)}: $e';
      });
    }
  }

  void _calculateQiblaDirection(double latitude, double longitude) {
    // Convert degrees to radians
    double lat1 = latitude * pi / 180;
    double lng1 = longitude * pi / 180;
    double lat2 = kaabaLat * pi / 180;
    double lng2 = kaabaLng * pi / 180;

    // Calculate the difference between the two longitudes
    double deltaLng = lng2 - lng1;

    // Calculate the Qibla direction
    double y = sin(deltaLng) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLng);
    double qiblaDirection = atan2(y, x);

    // Convert from radians to degrees and normalize to 0-360 range
    qiblaDirection = qiblaDirection * 180 / pi;
    qiblaDirection = (qiblaDirection + 360) % 360;

    setState(() {
      _qiblaDirection = qiblaDirection;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(AppStrings.getString('qiblaFinder', currentLocale),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: _isLoading
          ? _buildShimmerLoading(currentLocale)
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: GoogleFonts.poppins(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                ),
                child: Text(
                  AppStrings.getString('retry', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      )
          : StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.mainColor),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('initializingCompass', currentLocale),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.heading == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.compass_calibration,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('compassNotAvailable', currentLocale),
                    style: GoogleFonts.poppins(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final heading = snapshot.data!.heading!;
          final angle = (_qiblaDirection - heading) * (pi / 180);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Text(
                    AppStrings.getString('qiblaInstructions', currentLocale),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white,
                            Colors.grey[200]!,
                            Colors.grey[300]!
                          ],
                          center: Alignment.center,
                          radius: 0.9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.explore,
                            size: 100, color: AppColors.mainColor),
                      ),
                    ),
                    Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 280,
                        height: 280,
                        alignment: Alignment.topCenter,
                        child: Image.asset('assets/images/com.png',
                            height: 70, width: 70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                    "${AppStrings.getString('compass', currentLocale)}: ${heading.toStringAsFixed(0)}°",
                    style: GoogleFonts.poppins(fontSize: 18)
                ),
                Text(
                  "${AppStrings.getString('qibla', currentLocale)}: ${_qiblaDirection.toStringAsFixed(0)}°",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: AppColors.mainColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppStrings.getString('facingQibla', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              children: [
                Container(
                  height: 20,
                  width: 200,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
                Container(
                  height: 16,
                  width: 180,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Container(
                  height: 16,
                  width: 160,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.getString('findingQiblaDirection', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}