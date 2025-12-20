import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/services/location_service.dart';

class LocationPermissionDialog extends StatelessWidget {
  final Function(bool success) onResult;
  final LocationStatus? locationStatus;
  final String? title;
  final String? message;

  const LocationPermissionDialog({
    super.key,
    required this.onResult,
    this.locationStatus,
    this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isServiceDisabled = locationStatus == LocationStatus.serviceDisabled;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          Icon(
            Icons.location_on,
            size: 50,
            color: AppColors.mainColor,
          ),
          const SizedBox(height: 10),
          Text(
            title ?? (isServiceDisabled ? 'Enable Location Services' : 'Location Access Required'),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        message ?? (isServiceDisabled
            ? 'Location services are disabled on your device. Please enable them to use Rafahiya Tourism app features.'
            : 'Rafahiya Tourism needs access to your location to provide directions, nearby attractions, and better user experience.'),
        style: GoogleFonts.poppins(fontSize: 14),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onResult(false);
                },
                child: Text(
                  'Not Now',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool success = false;

                  if (isServiceDisabled) {
                    // Open location settings to enable service
                    await LocationService.openLocationSettings();

                    // Check if service is now enabled and we have permission
                    final newStatus = await LocationService.checkLocationStatus();
                    success = newStatus == LocationStatus.available;
                  } else {
                    // Handle permission request
                    final granted = await LocationService.requestLocationPermission();

                    if (granted) {
                      final position = await LocationService.getCurrentLocation();
                      if (position != null) {
                        await LocationService.saveUserLocation(
                            position.latitude,
                            position.longitude
                        );
                        success = true;
                      }
                    }
                  }

                  onResult(success);
                },
                child: Text(
                  isServiceDisabled ? 'Enable' : 'Allow',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}