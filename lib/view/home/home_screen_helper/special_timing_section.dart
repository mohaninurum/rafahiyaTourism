import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../../provider/home_masjid_data_provider.dart';
import '../../../utils/language/app_strings.dart';

class SpecialTimingsSection extends StatelessWidget {
  final int tabIndex;

  const SpecialTimingsSection({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Consumer<HomeMasjidDataProvider>(
      builder: (context, dataProvider, child) {
        final ramadanTimes = dataProvider.getRamadanTimes(tabIndex) ?? {
          'sehrTime': 'NA',
          'iftarTime': 'NA',
        };

        final sunsetTimes = dataProvider.getSunsetTimes(tabIndex) ?? {
          'tuluTime': 'NA',
          'zawalTime': 'NA',
          'gurubTime': 'NA',
        };

        final prohibitedTimes = dataProvider.getProhibitedTimes(tabIndex) ?? {
          'time1From': 'NA',
          'time1To': 'NA',
          'time2From': 'NA',
          'time2To': 'NA',
          'time3From': 'NA',
          'time3To': 'NA',
          'time4From': 'NA',
          'time4To': 'NA',
        };

        final specialNamazTimes = dataProvider.getSpecialNamazTimes(tabIndex) ?? {
          'namaz1Name': 'NA', 'namaz1Time': 'NA',
          'namaz2Name': 'NA', 'namaz2Time': 'NA',
          'namaz3Name': 'NA', 'namaz3Time': 'NA',
        };

        return Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings.getString('specialTimings', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              _buildTimingCard(
                context,
                title: AppStrings.getString('fastingTimes', currentLocale),
                icon: Icons.nightlight_round,
                color: Colors.blue,
                times: [
                  _buildTimingRow(
                      AppStrings.getString('sehrTime', currentLocale),
                      ramadanTimes['sehrTime']!,
                      currentLocale
                  ),
                  _buildTimingRow(
                      AppStrings.getString('iftarTime', currentLocale),
                      ramadanTimes['iftarTime']!,
                      currentLocale
                  ),
                ],
                currentLocale: currentLocale,
              ),

              _buildTimingCard(
                context,
                title: AppStrings.getString('sunsetTimings', currentLocale),
                icon: Icons.wb_sunny,
                color: Colors.orange,
                times: [
                  _buildTimingRow(
                      AppStrings.getString('tuluSunrise', currentLocale),
                      sunsetTimes['tuluTime']!,
                      currentLocale
                  ),
                  _buildTimingRow(
                      AppStrings.getString('zawalNoon', currentLocale),
                      sunsetTimes['zawalTime']!,
                      currentLocale
                  ),
                  _buildTimingRow(
                      AppStrings.getString('gurubSunset', currentLocale),
                      sunsetTimes['gurubTime']!,
                      currentLocale
                  ),
                ],
                currentLocale: currentLocale,
              ),

              _buildTimingCard(
                context,
                title: AppStrings.getString('prohibitedPrayerTimes', currentLocale),
                icon: Icons.not_interested,
                color: Colors.red,
                times: _buildProhibitedTimeRows(prohibitedTimes, currentLocale),
                currentLocale: currentLocale,
              ),
              _buildSpecialNamazCard(context, specialNamazTimes, currentLocale),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildProhibitedTimeRows(Map<String, String> prohibitedTimes, String currentLocale) {
    final List<Widget> rows = [];

    for (int i = 1; i <= 4; i++) {
      final fromTime = prohibitedTimes['time${i}From'] ?? 'NA';
      final toTime = prohibitedTimes['time${i}To'] ?? 'NA';

      if (fromTime != 'NA' || toTime != 'NA') {
        final timeRange = fromTime != 'NA' && toTime != 'NA'
            ? '$fromTime - $toTime'
            : fromTime != 'NA' ? 'From: $fromTime' : 'To: $toTime';

        rows.add(_buildTimingRow(
            '${AppStrings.getString('time', currentLocale)} $i',
            timeRange,
            currentLocale
        ));
      }
    }

    if (rows.isEmpty) {
      rows.add(_buildTimingRow(
          AppStrings.getString('noProhibitedTimes', currentLocale),
          'NA',
          currentLocale
      ));
    }

    return rows;
  }

  Widget _buildSpecialNamazCard(BuildContext context, Map<String, dynamic> specialNamazTimes, String currentLocale) {
    final List<Widget> namazRows = [];

    if (specialNamazTimes['namaz1Name'] != 'NA' && specialNamazTimes['namaz1Name']!.isNotEmpty) {
      namazRows.add(_buildTimingRow(
          specialNamazTimes['namaz1Name']!,
          specialNamazTimes['namaz1Time']!,
          currentLocale
      ));
    }

    if (specialNamazTimes['namaz2Name'] != 'NA' && specialNamazTimes['namaz2Name']!.isNotEmpty) {
      namazRows.add(_buildTimingRow(
          specialNamazTimes['namaz2Name']!,
          specialNamazTimes['namaz2Time']!,
          currentLocale
      ));
    }

    if (specialNamazTimes['namaz3Name'] != 'NA' && specialNamazTimes['namaz3Name']!.isNotEmpty) {
      namazRows.add(_buildTimingRow(
          specialNamazTimes['namaz3Name']!,
          specialNamazTimes['namaz3Time']!,
          currentLocale
      ));
    }

    if (namazRows.isEmpty) {
      namazRows.add(_buildTimingRow(
          AppStrings.getString('noSpecialNamazTimes', currentLocale),
          'NA',
          currentLocale
      ));
    }

    return _buildTimingCard(
      context,
      title: AppStrings.getString('specialNamazTimes', currentLocale),
      icon: Icons.access_time,
      color: Colors.green,
      times: namazRows,
      currentLocale: currentLocale,
    );
  }

  Widget _buildTimingCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required List<Widget> times,
        required String currentLocale,
      }) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: times,
          ),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String label, String time, String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              textAlign: TextAlign.right,
              time,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}