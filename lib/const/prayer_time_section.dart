// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:rafahiyatourism/const/color.dart';
// import 'package:rafahiyatourism/provider/locale_provider.dart';
//
// import '../../provider/home_masjid_data_provider.dart';
// import '../utils/language/app_strings.dart';
//
// class PrayerTimesSection extends StatelessWidget {
//   final int tabIndex;
//
//   const PrayerTimesSection({super.key, required this.tabIndex});
//
//   @override
//   Widget build(BuildContext context) {
//     final localeProvider = Provider.of<LocaleProvider>(context);
//     final currentLocale = localeProvider.locale?.languageCode ?? 'en';
//
//     print('PrayerTimesSection building for tab $tabIndex');
//     return Consumer<HomeMasjidDataProvider>(
//       builder: (context, dataProvider, child) {
//         final prayerTimes = dataProvider.getPrayerTimes(tabIndex);
//
//         if (prayerTimes == null || prayerTimes.isEmpty) {
//           return Container(
//             margin: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: AppColors.mainColor,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(12),
//                       topRight: Radius.circular(12),
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       AppStrings.getString('dailyPrayerTimes', currentLocale),
//                       style: GoogleFonts.poppins(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Center(
//                     child: Text(
//                       AppStrings.getString('noPrayerTimesAvailable', currentLocale),
//                       style: GoogleFonts.poppins(
//                         color: AppColors.mainColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Header
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.mainColor,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     AppStrings.getString('dailyPrayerTimes', currentLocale),
//                     style: GoogleFonts.poppins(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               // Content
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Header Row
//                     Row(
//                       children: [
//                         Container(
//                           width: 80,
//                           child: Text(
//                             AppStrings.getString('salah', currentLocale),
//                             style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.left,
//                           ),
//                         ),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               Expanded(
//                                 child: Center(
//                                   child: Text(
//                                       AppStrings.getString('azan', currentLocale),
//                                       style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Center(
//                                   child: Text(
//                                       AppStrings.getString('jamat', currentLocale),
//                                       style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Center(
//                                   child: Text(
//                                       AppStrings.getString('awal', currentLocale),
//                                       style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: Center(
//                                   child: Text(
//                                       AppStrings.getString('akhir', currentLocale),
//                                       style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Divider(),
//
//                     // Prayer Rows
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Prayer names column
//                         Container(
//                           width: 80,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: _getPrayerOrder(currentLocale).map((prayerName) {
//                               return Container(
//                                 height: 40,
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   prayerName,
//                                   style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//
//                         Expanded(
//                           child: Column(
//                             children: _getPrayerOrder(currentLocale).map((prayerName) {
//                               final englishPrayerName = _getEnglishPrayerName(prayerName);
//                               final prayerData = prayerTimes[englishPrayerName];
//                               print('DOCS: $englishPrayerName, Data: $prayerData');
//
//                               final azaanTime = _getTime(prayerData, 'azaanTime');
//                               final jammatTime = _getTime(prayerData, 'jammatTime');
//                               final awwalTime = _getTime(prayerData, 'awalTime');
//                               final akhirTime = _getTime(prayerData, 'akhirTime');
//
//                               print('awwalTime $awwalTime');
//                               print('akhirTime $akhirTime');
//
//                               return SizedBox(
//                                 height: 40,
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Center(
//                                         child: _buildTimeText(azaanTime),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Center(
//                                         child: _buildTimeText(jammatTime),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Center(
//                                         child: _buildTimeText(awwalTime),
//                                       ),
//                                     ),
//                                     Expanded(
//                                       child: Center(
//                                         child: _buildTimeText(akhirTime),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   List<String> _getPrayerOrder(String currentLocale) {
//     return [
//       AppStrings.getString('fajr', currentLocale),
//       AppStrings.getString('dhuhr', currentLocale),
//       AppStrings.getString('asr', currentLocale),
//       AppStrings.getString('maghrib', currentLocale),
//       AppStrings.getString('isha', currentLocale),
//     ];
//   }
//
//   String _getEnglishPrayerName(String localizedName) {
//     // Convert localized prayer name back to English for data lookup
//     if (localizedName.contains('فجر') || localizedName.contains('फज्र')) return 'Fajr';
//     if (localizedName.contains('ظهر') || localizedName.contains('जुहर')) return 'Dhuhr';
//     if (localizedName.contains('عصر') || localizedName.contains('अस्र')) return 'Asr';
//     if (localizedName.contains('مغرب') || localizedName.contains('मग़रिब')) return 'Maghrib';
//     if (localizedName.contains('عشاء') || localizedName.contains('इशा')) return 'Isha';
//     return localizedName; // fallback
//   }
//
//   String _getTime(dynamic prayerData, String fieldName) {
//     if (prayerData is Map) {
//       final time = prayerData[fieldName]?.toString() ?? 'NA';
//       print('$fieldName: $time'); // Debug print
//       return time;
//     }
//     return 'NA';
//   }
//
//   Widget _buildTimeText(String time) {
//     return Text(
//       time,
//       style: GoogleFonts.poppins(
//         color: time == 'NA' ? Colors.grey : Colors.black,
//       ),
//     );
//   }
// }



import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../provider/home_masjid_data_provider.dart';
import '../utils/language/app_strings.dart';

class PrayerTimesSection extends StatefulWidget {
  final int tabIndex;

  const PrayerTimesSection({super.key, required this.tabIndex});

  @override
  State<PrayerTimesSection> createState() => _PrayerTimesSectionState();
}

class _PrayerTimesSectionState extends State<PrayerTimesSection> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final cleaned = timeStr
          .replaceAll('\u00A0', ' ')
          .replaceAll('\u202F', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (cleaned.isEmpty || cleaned == 'NA' || cleaned.toLowerCase() == 'not set') {
        return const TimeOfDay(hour: 23, minute: 59); // Far future time
      }

      // Try multiple time formats
      TimeOfDay? timeOfDay;

      // Format 1: Try parsing as 12-hour format with AM/PM (e.g., "7:47 PM")
      try {
        final format12Hour = DateFormat.jm();
        final dateTime = format12Hour.parse(cleaned);
        timeOfDay = TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        // Format 2: Try parsing as 24-hour format (HH:mm)
        final match24Hour = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(cleaned);
        if (match24Hour != null) {
          final hour = int.parse(match24Hour.group(1)!);
          final minute = int.parse(match24Hour.group(2)!);
          if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            timeOfDay = TimeOfDay(hour: hour, minute: minute);
          }
        }

        if (timeOfDay == null) {
          final match12Hour = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$').firstMatch(cleaned);
          if (match12Hour != null) {
            var hour = int.parse(match12Hour.group(1)!);
            final minute = int.parse(match12Hour.group(2)!);
            final period = match12Hour.group(3)!.toUpperCase();

            if (period == 'PM' && hour != 12) {
              hour += 12;
            } else if (period == 'AM' && hour == 12) {
              hour = 0;
            }
            if (hour == 24) hour = 0; // Handle midnight

            timeOfDay = TimeOfDay(hour: hour, minute: minute);
          }
        }
      }

      return timeOfDay ?? const TimeOfDay(hour: 23, minute: 59);
    } catch (e) {
      debugPrint("Failed to parse time: '$timeStr'. Error: $e");
      return const TimeOfDay(hour: 23, minute: 59);
    }
  }

  bool _isBetweenTimes(TimeOfDay startTime, TimeOfDay endTime) {
    final now = TimeOfDay.fromDateTime(_currentTime);

    int nowInMinutes = now.hour * 60 + now.minute;
    int startInMinutes = startTime.hour * 60 + startTime.minute;
    int endInMinutes = endTime.hour * 60 + endTime.minute;

    // Handle overnight case (e.g., Isha to Fajr)
    if (endInMinutes < startInMinutes) {
      return nowInMinutes >= startInMinutes || nowInMinutes <= endInMinutes;
    }

    return nowInMinutes >= startInMinutes && nowInMinutes <= endInMinutes;
  }

  String? getCurrentOngoingPrayer(Map<String, dynamic> prayerTimes) {
    final now = TimeOfDay.fromDateTime(_currentTime);

    // Define prayer order for the day
    final prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    // Check each prayer to see if current time is between its azaan and akhir times
    for (var prayer in prayerOrder) {
      final prayerData = prayerTimes[prayer];
      if (prayerData != null &&
          prayerData['azaanTime'] != null &&
          prayerData['akhirTime'] != null &&
          prayerData['azaanTime'] != 'NA' &&
          prayerData['akhirTime'] != 'NA') {

        final azaanTime = _parseTime(prayerData['azaanTime']);
        final akhirTime = _parseTime(prayerData['akhirTime']);

        if (_isBetweenTimes(azaanTime, akhirTime)) {
          return prayer;
        }
      }
    }

    return null;
  }

  void _debugPrayerTimes(Map<String, dynamic> prayerTimes) {
    debugPrint('=== DEBUG PRAYER TIMES ===');
    debugPrint('Current Time: ${TimeOfDay.fromDateTime(_currentTime)}');

    final prayerOrder = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (var prayer in prayerOrder) {
      final prayerData = prayerTimes[prayer];
      if (prayerData != null) {
        final azaanTime = _parseTime(prayerData['azaanTime'] ?? 'NA');
        final akhirTime = _parseTime(prayerData['akhirTime'] ?? 'NA');
        final isCurrent = getCurrentOngoingPrayer(prayerTimes) == prayer;
        debugPrint('$prayer: Azaan: ${prayerData['azaanTime']} -> $azaanTime | Akhir: ${prayerData['akhirTime']} -> $akhirTime | Is Current: $isCurrent');
      }
    }

    final currentPrayer = getCurrentOngoingPrayer(prayerTimes);
    debugPrint('Current Ongoing Prayer: $currentPrayer');
    debugPrint('=====================');
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    print('PrayerTimesSection building for tab ${widget.tabIndex}');
    return Consumer<HomeMasjidDataProvider>(
      builder: (context, dataProvider, child) {
        final prayerTimes = dataProvider.getPrayerTimes(widget.tabIndex);

        if (prayerTimes == null || prayerTimes.isEmpty) {
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
                // Header
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
                      AppStrings.getString('dailyPrayerTimes', currentLocale),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      AppStrings.getString('noPrayerTimesAvailable', currentLocale),
                      style: GoogleFonts.poppins(
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Debug the prayer times
        _debugPrayerTimes(prayerTimes);

        final currentOngoingPrayer = getCurrentOngoingPrayer(prayerTimes);

        return Container(
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
              // Header
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
                    AppStrings.getString('dailyPrayerTimes', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Content
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          width: 80,
                          child: Text(
                            AppStrings.getString('salah', currentLocale),
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                      AppStrings.getString('azan', currentLocale),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                      AppStrings.getString('jamat', currentLocale),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                      AppStrings.getString('awal', currentLocale),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                      AppStrings.getString('akhir', currentLocale),
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Prayer Rows
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prayer names column
                        Container(
                          width: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _getPrayerOrder(currentLocale).map((prayerName) {
                              final englishPrayerName = _getEnglishPrayerName(prayerName);
                              final isCurrent = currentOngoingPrayer == englishPrayerName;

                              return Container(
                                // height: 40,
                                padding: EdgeInsets.all(6),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.mainColor.withOpacity(0.8) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    prayerName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.bold,
                                      color: isCurrent ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        Expanded(
                          child: Column(
                            children: _getPrayerOrder(currentLocale).map((prayerName) {
                              final englishPrayerName = _getEnglishPrayerName(prayerName);
                              final prayerData = prayerTimes[englishPrayerName];
                              final isCurrent = currentOngoingPrayer == englishPrayerName;

                              print('DOCS: $englishPrayerName, Data: $prayerData');

                              final azaanTime = _getTime(prayerData, 'azaanTime');
                              final jammatTime = _getTime(prayerData, 'jammatTime');
                              final awwalTime = _getTime(prayerData, 'awalTime');
                              final akhirTime = _getTime(prayerData, 'akhirTime');

                              print('awwalTime $awwalTime');
                              print('akhirTime $akhirTime');

                              return Container(
                                // height: 40,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isCurrent ? AppColors.mainColor.withOpacity(0.8) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: _buildTimeText(azaanTime, isCurrent: isCurrent),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: _buildTimeText(jammatTime, isCurrent: isCurrent),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: _buildTimeText(awwalTime, isCurrent: isCurrent),
                                      ),
                                    ),
                                    Expanded(
                                      child: Center(
                                        child: _buildTimeText(akhirTime, isCurrent: isCurrent),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getPrayerOrder(String currentLocale) {
    return [
      AppStrings.getString('fajr', currentLocale),
      AppStrings.getString('dhuhr', currentLocale),
      AppStrings.getString('asr', currentLocale),
      AppStrings.getString('maghrib', currentLocale),
      AppStrings.getString('isha', currentLocale),
    ];
  }

  String _getEnglishPrayerName(String localizedName) {
    if (localizedName.contains('فجر') || localizedName.contains('फज्र')) return 'Fajr';
    if (localizedName.contains('ظهر') || localizedName.contains('जुहर')) return 'Dhuhr';
    if (localizedName.contains('عصر') || localizedName.contains('अस्र')) return 'Asr';
    if (localizedName.contains('مغرب') || localizedName.contains('मग़रिब')) return 'Maghrib';
    if (localizedName.contains('عشاء') || localizedName.contains('इशा')) return 'Isha';
    return localizedName; // fallback
  }

  String _getTime(dynamic prayerData, String fieldName) {
    if (prayerData is Map) {
      final time = prayerData[fieldName]?.toString() ?? 'NA';
      print('$fieldName: $time'); // Debug print
      return time;
    }
    return 'NA';
  }

  Widget _buildTimeText(String time, {bool isCurrent = false}) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        time,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.poppins(
          color: time == 'NA' ? Colors.grey : (isCurrent ? Colors.white : Colors.black),
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }


}