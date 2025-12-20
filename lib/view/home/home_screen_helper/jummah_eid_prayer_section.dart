

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../../provider/home_masjid_data_provider.dart';
import '../../../utils/language/app_strings.dart';

class JummahEidPrayerSection extends StatelessWidget {
  final int tabIndex;

  const JummahEidPrayerSection({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Consumer<HomeMasjidDataProvider>(
      builder: (context, dataProvider, child) {
        final jumuahTimes = dataProvider.getJumuahTimes(tabIndex) ?? {
          'Jumuah 1': {'azanTime': 'NA', 'khutbaTime': 'NA', 'jammatTime': 'NA'},
          'Jumuah 2': {'azanTime': 'NA', 'khutbaTime': 'NA', 'jammatTime': 'NA'},
        };

        final eidTimes = dataProvider.getEidTimes(tabIndex) ?? {
          'Eid': {'jammat1': 'NA', 'jammat2': 'NA'},
        };

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.sp),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding:  EdgeInsets.all(16.sp),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius:  BorderRadius.only(
                    topLeft: Radius.circular(12.sp),
                    topRight: Radius.circular(12.sp),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings.getString('jumuahEidPrayers', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Content
              Container(
                padding: EdgeInsets.all(16.sp),
                child: Column(
                  children: [
                    // Jumuah Header Row
                    _buildJumuahHeaderRow(currentLocale),
                    const Divider(),

                    // Jumuah Prayer Rows
                    _buildJumuahPrayerRows(jumuahTimes, currentLocale),

                    SizedBox(height: 16.h),

                    _buildEidHeaderRow(currentLocale),
                    const Divider(),

                    _buildEidPrayerRows(eidTimes, currentLocale),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJumuahHeaderRow(String currentLocale) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            AppStrings.getString('jumuah', currentLocale),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                  AppStrings.getString('azan', currentLocale),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
              ),
              Text(
                  AppStrings.getString('khutba', currentLocale),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
              ),
              Text(
                  AppStrings.getString('jamat', currentLocale),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEidHeaderRow(String currentLocale) {
    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            AppStrings.getString('eidNamaz', currentLocale),
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                  AppStrings.getString('jamat1', currentLocale),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
              ),
              Text(
                  AppStrings.getString('jamat2', currentLocale),
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
              ),
              SizedBox(width: 40.w), // Placeholder for alignment
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJumuahPrayerRows(Map<String, Map<String, String>> jumuahTimes, String currentLocale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: jumuahTimes.keys.map((jumuahName) {
              return Container(
                height: 40.h,
                alignment: Alignment.centerLeft,
                child: Text(
                  jumuahName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold,fontSize: 15.sp),
                ),
              );
            }).toList(),
          ),
        ),
        // Jumuah times column
        Expanded(
          child: Column(
            children: jumuahTimes.values.map((times) {
              return SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeText(times['azanTime'] ?? 'NA'),
                    _buildTimeText(times['khutbaTime'] ?? 'NA'),
                    _buildTimeText(times['jammatTime'] ?? 'NA'),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEidPrayerRows(Map<String, Map<String, String>> eidTimes, String currentLocale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: eidTimes.keys.map((eidName) {
              return Container(
                height: 40.h,
                alignment: Alignment.centerLeft,
                child: Text(
                  eidName,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: Column(
            children: eidTimes.values.map((times) {
              return SizedBox(
                height: 40.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTimeText(times['jammat1'] ?? 'NA'),
                    _buildTimeText(times['jammat2'] ?? 'NA'),
                    SizedBox(width: 40.w), // Placeholder for alignment
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeText(String time) {
    return Text(
      time,
      style: GoogleFonts.poppins(
        color: time == 'NA' ? Colors.grey : Colors.black,
      ),
    );
  }
}




