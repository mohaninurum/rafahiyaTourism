


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/home/home_screen_helper/request_update_screen.dart';

import '../../../provider/home_masjid_data_provider.dart';
import '../../../provider/locale_provider.dart';
import '../../../provider/multi_mosque_provider.dart';
import '../../super_admin_code/superadminprovider/hijri_date_provider/hijri_date_provider.dart';

class MasjidInfoCard extends StatelessWidget {
  final int tabIndex;

  const MasjidInfoCard({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer4<MultiMosqueProvider, HomeMasjidDataProvider, HijriDateProvider, LocaleProvider>(
      builder: (context, multiProvider, dataProvider, hijriDateProvider, localeProvider, child) {
        final currentLocale = localeProvider.locale?.languageCode ?? 'en';

        final detailedMosqueData = dataProvider.getMosqueData(tabIndex);
        final userId = detailedMosqueData?['uid'] ?? "";
        final imamName = detailedMosqueData?['imamName'] ?? 'SubAdmin';
        final phoneNumber = detailedMosqueData?['phone'] ?? '+91 95523 78468';
        final mosqueName = detailedMosqueData?['name'] ?? AppStrings.getString('demoMasjid', currentLocale);

        final mosqueCountry = _getMosqueCountry(detailedMosqueData);

        final now = DateTime.now();
        final gregorianDate = DateFormat('MMMM dd, yyyy').format(now);

        final hijriDateData = hijriDateProvider.getHijriDateForMosque(
            detailedMosqueData?['id'] ?? '',
            detailedMosqueData
        );
        final islamicDate = hijriDateData['fullDate'] ?? _getDefaultIslamicDate(now);

        final lastUpdateTime = dataProvider.getLastGeneralUpdateTime(tabIndex);
        final formattedLastUpdateTime = lastUpdateTime != null
            ? DateFormat('dd MMMM yyyy, hh:mm a').format(lastUpdateTime)
            : AppStrings.getString('notAvailable', currentLocale);

        final bool canRequestUpdate = lastUpdateTime == null ||
            now.difference(lastUpdateTime).inDays >= 4;

        return Container(
          decoration: BoxDecoration(color: AppColors.mainColor),
          padding:  EdgeInsets.all(12.sp),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:  EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green[900],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    "${AppStrings.getString('lastUpdate', currentLocale)}: $formattedLastUpdateTime",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 45.h,
                                width: MediaQuery.of(context).size.width/2.4,
                                decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.whiteColor),
                                    borderRadius: BorderRadius.circular(5)
                                ),
                                child: Center(
                                  child: _infoRow(AppStrings.getString('adminName', currentLocale), imamName),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                height: 45.h,
                                width: MediaQuery.of(context).size.width/2.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.whiteColor),
                                ),
                                child: Center(
                                  child: _infoRow(AppStrings.getString('adminNumber', currentLocale), phoneNumber),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${AppStrings.getString('today', currentLocale)}:",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  color: AppColors.whiteColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gregorianDate.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12.sp,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                    Text(
                                      " ($islamicDate)",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11.sp,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: InkWell(
                                onTap: canRequestUpdate
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RequestUpdateScreen(
                                        userId: userId,
                                        imamName: imamName,
                                        mosqueName: mosqueName,
                                      ),
                                    ),
                                  );
                                }
                                    : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Updated Recently',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 40.h,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: canRequestUpdate ? Colors.white : Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: FittedBox(
                                      child: Text(
                                        "${AppStrings.getString('requestUpdate', currentLocale)} >",
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w700,
                                          color: canRequestUpdate ? AppColors.mainColor : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String? _getMosqueCountry(Map<String, dynamic>? mosqueData) {
    if (mosqueData == null) return null;

    if (mosqueData['location'] != null && mosqueData['location'] is Map<String, dynamic>) {
      final location = mosqueData['location'] as Map<String, dynamic>;
      if (location['country'] != null) {
        return location['country'].toString();
      }
    }

    if (mosqueData['address'] != null) {
      final address = mosqueData['address'].toString();
      if (address.toLowerCase().contains('saudi')) return 'Saudi Arabia';
      if (address.toLowerCase().contains('uae')) return 'United Arab Emirates';
      if (address.toLowerCase().contains('qatar')) return 'Qatar';
    }

    if (mosqueData['city'] != null) {
      return mosqueData['city'].toString();
    }

    return null;
  }

  String _getDefaultIslamicDate(DateTime date) {
    try {
      final hijriDate = HijriCalendar.fromDate(date);
      return '${hijriDate.hDay} ${_getIslamicMonthName(hijriDate.hMonth)} ${hijriDate.hYear} AH';
    } catch (e) {
      return _getIslamicDateFallback(date);
    }
  }

  String _getIslamicMonthName(int month) {
    switch (month) {
      case 1: return 'Muharram';
      case 2: return 'Safar';
      case 3: return 'Rabi al-Awwal';
      case 4: return 'Rabi al-Thani';
      case 5: return 'Jumada al-Awwal';
      case 6: return 'Jumada al-Thani';
      case 7: return 'Rajab';
      case 8: return 'Sha\'ban';
      case 9: return 'Ramadan';
      case 10: return 'Shawwal';
      case 11: return 'Dhu al-Qi\'dah';
      case 12: return 'Dhu al-Hijjah';
      default: return 'Unknown';
    }
  }

  String _getIslamicDateFallback(DateTime date) {
    final gregorianYear = date.year;
    final hijriYear = ((gregorianYear - 622) * 0.97).round();

    final daysSinceEpoch = date.difference(DateTime(622, 7, 16)).inDays;
    final hijriTotalMonths = (daysSinceEpoch / 29.53).round();
    final hijriMonth = (hijriTotalMonths % 12) + 1;
    final hijriDay = (daysSinceEpoch % 29.53).round() + 1;

    final monthName = _getIslamicMonthName(hijriMonth);
    return '$hijriDay $monthName $hijriYear AH';
  }

  Widget _infoRow(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "$label: ",
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.whiteColor,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.whiteColor),
        ),
      ],
    );
  }
}