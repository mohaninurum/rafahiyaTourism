

import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/utils/capitalize_extension.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/prohibited_timing/prohibited_timing_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/ramzan_timing/ramzan_timing_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/special_namaz/special_namaz_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/sunset_timing/sunset_timing_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/setting/general_announcement.dart';

import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../data/models/eid_timings_model.dart';
import '../../data/models/hadiya_model.dart';
import '../../data/models/salah_timing_model.dart';
import '../../data/subAdminProvider/add_hadiya_maulana_provider.dart';
import '../../data/subAdminProvider/bayan_provider.dart';
import '../../data/subAdminProvider/prayer_times_provider.dart';
import '../../data/subAdminProvider/sub_admin_profile_provider.dart';
import '../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../hadiya_display_screen.dart';
import '../widgets/hadiya_detail_form.dart';
import 'eid_timing/eid_timing_screen.dart';
import 'jumma_timing/jumma_timing_screen.dart';
import 'namaz_timing/namaz_timing_screen.dart';

class SubAdminHomeScreen extends StatefulWidget {
  const SubAdminHomeScreen({super.key});

  @override
  State<SubAdminHomeScreen> createState() => _SubAdminHomeScreenState();
}

class _SubAdminHomeScreenState extends State<SubAdminHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _mosqueOffsetAnimation;
  late final Stream<EidTiming> _azhaStream;
  late final Stream<EidTiming> _fitrStream;

  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  String get formattedDate {
    final currentLocale = _getCurrentLocale(context);
    try {
      return DateFormat('d MMMM y', currentLocale).format(_currentTime);
    } catch (e) {
      return DateFormat('d MMMM y').format(_currentTime);
    }
  }

  String get formattedTime {
    final currentLocale = _getCurrentLocale(context);
    try {
      return DateFormat('h:mm a', currentLocale).format(_currentTime);
    } catch (e) {
      return DateFormat('h:mm a').format(_currentTime);
    }
  }

  bool _isFirstBuild = true;

  Widget _tableHeader(String title) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  static List<TableRow> _eidTimingsRows({
    required String fitrJamaat1,
    required String fitrJamaat2,
    required String azhaJamaat1,
    required String azhaJamaat2,
  }) {
    return [
      TableRow(
        children: [
          _tableCell("1st Jamaat: $fitrJamaat1"),
          _tableCell("1st Jamaat: $azhaJamaat1"),
        ],
      ),
      TableRow(
        children: [
          _tableCell("2nd Jamaat: $fitrJamaat2"),
          _tableCell("2nd Jamaat: $azhaJamaat2"),
        ],
      ),
    ];
  }

  static Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _hadiyaRow(HadiyaModel hadiya, VoidCallback onEdit) {
    final currentLocale = _getCurrentLocale(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hadiya.type,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Text(
                  AppStrings.getString('requestForChange', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hadiya.bankDetails,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                hadiya.accountNumber,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.getString('qrCode', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Image.asset("assets/images/com.png", height: 50),
            ],
          ),
        ],
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  MapEntry<String, SalahTime>? getNextSalah(SalahTimings timings) {
    final now = TimeOfDay.fromDateTime(_currentTime);

    // Convert all salah times to minutes for proper comparison
    final salahList = timings.timings.entries.map((entry) {
      final jamaatTime = _parseTime(entry.value.jammatTime);
      final minutes = jamaatTime.hour * 60 + jamaatTime.minute;
      return {
        'entry': entry,
        'minutes': minutes,
        'time': jamaatTime,
      };
    }).toList();

    // Sort by time (earliest first) - with null safety
    salahList.sort((a, b) {
      final aMinutes = a['minutes'] as int;
      final bMinutes = b['minutes'] as int;
      return aMinutes.compareTo(bMinutes);
    });

    // Find the next salah that hasn't passed yet
    final nowMinutes = now.hour * 60 + now.minute;

    for (var salah in salahList) {
      final salahMinutes = salah['minutes'] as int;
      if (salahMinutes > nowMinutes) {
        return salah['entry'] as MapEntry<String, SalahTime>;
      }
    }

    // If all salahs have passed for today, return the first salah of next day
    return salahList.isNotEmpty ? salahList.first['entry'] as MapEntry<String, SalahTime> : null;
  }


  TimeOfDay _parseTime(String timeStr) {
    try {
      final cleaned = timeStr
          .replaceAll('\u00A0', ' ')
          .replaceAll('\u202F', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (cleaned.isEmpty || cleaned.toLowerCase() == 'not set') {
        return const TimeOfDay(hour: 23, minute: 59); // Far future
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

        // Format 3: Try parsing with space-separated AM/PM (e.g., "7:47 PM")
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

  bool _isAfter(TimeOfDay now, TimeOfDay compare) {
    // Convert to minutes for accurate comparison
    final nowMinutes = now.hour * 60 + now.minute;
    final compareMinutes = compare.hour * 60 + compare.minute;

    return compareMinutes > nowMinutes;
  }

  void _showHadiyaForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.getString('addBankDetails', _getCurrentLocale(context)),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: HadiyaBankDetailsForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _addMinutes(String timeStr, int minutesToAdd) {
    final timeParts = timeStr.split(":");
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    minute += minutesToAdd;
    if (minute >= 60) {
      hour += minute ~/ 60;
      minute = minute % 60;
    }

    final period = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final formatted =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    return formatted;
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _mosqueOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final provider = context.read<SubAdminTimingsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubAdminProfileProvider>().getProfile(userId);
      Provider.of<PrayerTimesProvider>(
        context,
        listen: false,
      ).fetchPrayerTimes();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstBuild) {
      _isFirstBuild = false;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        Provider.of<HadiyaProvider>(context, listen: false).listenToHadiya(uid);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final hadiyaList = Provider.of<HadiyaProvider>(context).hadiyaList;
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);

    String _getPrayerTimeWithJamaat(String? prayerTime, int minutes) {
      if (prayerTime == null || prayerTime.isEmpty) {
        return 'Not Available';
      }
      return _addMinutes(prayerTime, minutes);
    }

    final text = prayerProvider.isLoading
        ? AppStrings.getString('loadingPrayerTimes', currentLocale)
        : '${AppStrings.getString('fajrAzaan', currentLocale)}: ${prayerProvider.fajr ?? 'Not Available'} | ${AppStrings.getString('jamaat', currentLocale)}: ${_getPrayerTimeWithJamaat(prayerProvider.fajr, 15)}      '
        '${AppStrings.getString('dhuhrAzaan', currentLocale)}: ${prayerProvider.dhuhr ?? 'Not Available'} | ${AppStrings.getString('jamaat', currentLocale)}: ${_getPrayerTimeWithJamaat(prayerProvider.dhuhr, 15)}      '
        '${AppStrings.getString('asrAzaan', currentLocale)}: ${prayerProvider.asr ?? 'Not Available'} | ${AppStrings.getString('jamaat', currentLocale)}: ${_getPrayerTimeWithJamaat(prayerProvider.asr, 15)}      '
        '${AppStrings.getString('maghribAzaan', currentLocale)}: ${prayerProvider.maghrib ?? 'Not Available'} | ${AppStrings.getString('jamaat', currentLocale)}: ${_getPrayerTimeWithJamaat(prayerProvider.maghrib, 15)}      '
        '${AppStrings.getString('ishaAzaan', currentLocale)}: ${prayerProvider.isha ?? 'Not Available'} | ${AppStrings.getString('jamaat', currentLocale)}: ${_getPrayerTimeWithJamaat(prayerProvider.isha, 15)}';

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/container_image.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            SlideTransition(
              position: _mosqueOffsetAnimation,
              child: Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/masjid.png"),
                    ),
                  ),
                ),
              ),
            ),

            Consumer<SubAdminProfileProvider>(
              builder: (context, provider, _) {
                final profile = provider.profile;

                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (profile == null) {
                  return Text(AppStrings.getString('profileNotFound', currentLocale));
                }

                return Column(
                  children: [
                    SlideTransition(
                      position: _mosqueOffsetAnimation,
                      child: Center(
                        child: Text(
                          profile?.imamName ?? AppStrings.getString('imamName', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackBackground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SlideTransition(
                      position: _mosqueOffsetAnimation,
                      child: Center(
                        child: Text(
                          profile?.masjidName ?? AppStrings.getString('masjidName', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackBackground,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Consumer<SubAdminTimingsProvider>(
            //   builder: (context,timingsProvider,child){
            //     return StreamBuilder<SalahTimings>(
            //       stream: timingsProvider.streamAllSalahTimings(
            //         FirebaseAuth.instance.currentUser!.uid,
            //       ),
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return Container(
            //             height: 40,
            //             color: Colors.black.withAlpha(102),
            //             child: Center(
            //               child: Text(
            //                 AppStrings.getString('loadingPrayerTimes', currentLocale),
            //                 style: GoogleFonts.poppins(
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ),
            //           );
            //         }
            //
            //         if (snapshot.hasError) {
            //           return Container(
            //             height: 40,
            //             color: Colors.black.withAlpha(102),
            //             child: Center(
            //               child: Text(
            //                 AppStrings.getString('errorLoadingTimes', currentLocale),
            //                 style: GoogleFonts.poppins(
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ),
            //           );
            //         }
            //
            //         if (!snapshot.hasData) {
            //           return Container(
            //             height: 40,
            //             color: Colors.black.withAlpha(102),
            //             child: Center(
            //               child: Text(
            //                 AppStrings.getString('noPrayerTimes', currentLocale),
            //                 style: GoogleFonts.poppins(
            //                   fontWeight: FontWeight.w700,
            //                   color: Colors.white,
            //                   fontSize: 16,
            //                 ),
            //               ),
            //             ),
            //           );
            //         }
            //
            //         final salahTimings = snapshot.data!;
            //         final timings = salahTimings.timings;
            //
            //         String marqueeText = '';
            //
            //         // Helper function to get prayer time or "Not Set"
            //         String _getPrayerTime(String prayerName) {
            //           if (timings.containsKey(prayerName)) {
            //             final prayer = timings[prayerName];
            //             if (prayer != null &&
            //                 prayer.azaanTime.isNotEmpty &&
            //                 prayer.jammatTime.isNotEmpty &&
            //                 prayer.azaanTime != 'Not set' &&
            //                 prayer.jammatTime != 'Not set') {
            //               return '${AppStrings.getString('${prayerName}Azaan', currentLocale)}: ${prayer.azaanTime} | ${AppStrings.getString('jamaat', currentLocale)}: ${prayer.jammatTime}      ';
            //             }
            //           }
            //           return '${AppStrings.getString('${prayerName}Azaan', currentLocale)}: ${AppStrings.getString('notSet', currentLocale)} | ${AppStrings.getString('jamaat', currentLocale)}: ${AppStrings.getString('notSet', currentLocale)}      ';
            //         }
            //
            //         // Add all prayers
            //         marqueeText += _getPrayerTime('fajr');
            //         marqueeText += _getPrayerTime('dhuhr');
            //         marqueeText += _getPrayerTime('asr');
            //         marqueeText += _getPrayerTime('maghrib');
            //         marqueeText += _getPrayerTime('isha');
            //
            //         if (marqueeText.isEmpty) {
            //           marqueeText = AppStrings.getString('noPrayerTimesAvailable', currentLocale);
            //         }
            //
            //         return Container(
            //           height: 40,
            //           color: Colors.black.withAlpha(102),
            //           child: Marquee(
            //             text: marqueeText,
            //             style: GoogleFonts.poppins(
            //               fontWeight: FontWeight.w700,
            //               color: Colors.white,
            //               fontSize: 16,
            //             ),
            //             velocity: 40.0,
            //             blankSpace: 100.0,
            //             pauseAfterRound: Duration(seconds: 1),
            //             startPadding: 10.0,
            //           ),
            //         );
            //       },
            //     );
            //   },
            //
            // ),

            // Container(
            //   margin: const EdgeInsets.all(15),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(8),
            //     boxShadow: [
            //       BoxShadow(
            //         color: AppColors.blackColor.withAlpha(13),
            //         blurRadius: 6,
            //         offset: Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: ExpansionTile(
            //     title: Text(
            //       AppStrings.getString('hadiya', currentLocale),
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            //     ),
            //     childrenPadding: const EdgeInsets.symmetric(
            //       horizontal: 0,
            //       vertical: 8,
            //     ),
            //     children:
            //     hadiyaList.isEmpty
            //         ? [
            //       Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Text(
            //           AppStrings.getString('noHadiyaData', currentLocale),
            //           style: TextStyle(
            //             color: Colors.grey[700],
            //             fontStyle: FontStyle.italic,
            //           ),
            //         ),
            //       ),
            //     ]
            //         : hadiyaList.map((hadiya) {
            //       return Column(
            //         children: [
            //           ListTile(
            //             title: Text(
            //               hadiya.type,
            //               style: GoogleFonts.poppins(
            //                 fontSize: 14,
            //                 fontWeight: FontWeight.w600,
            //               ),
            //             ),
            //             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            //             onTap: () {
            //               Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (_) => HadiyaDetailScreen(hadiya: hadiya),
            //                 ),
            //               );
            //             },
            //           ),
            //           Divider(
            //             thickness: 1,
            //             color: AppColors.blackColor,
            //           ),
            //         ],
            //       );
            //     }).toList(),
            //   ),
            // ),


            StreamBuilder<SalahTimings>(
              stream: context
                  .read<SubAdminTimingsProvider>()
                  .streamAllSalahTimings(
                FirebaseAuth.instance.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final timings = snapshot.data!;
                final nextSalah = getNextSalah(timings);

                return Container(
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.getString('nextSalah', currentLocale),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackBackground,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Text(
                              formattedDate,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackBackground,
                              ),
                            ),
                            // Text(
                            //   nextSalah?.key.capitalize() ?? "-",
                            //   style: GoogleFonts.poppins(
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w800,
                            //     color: AppColors.blackBackground,
                            //   ),
                            // ),
                            const SizedBox(height: 5.0),
                            Text(
                              '${AppStrings.getString('azaan', currentLocale)}: ${nextSalah?.value.azaanTime ?? "-"}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: Date + Jammat Time
                      SlideTransition(
                        position: _mosqueOffsetAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              nextSalah?.key.capitalize() ?? "-",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackBackground,
                              ),
                            ),

                            const SizedBox(height: 6),
                            Text(
                              "${AppStrings.getString('currentTime', currentLocale)} $formattedTime",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackBackground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${AppStrings.getString('jamaat', currentLocale)}: ${nextSalah?.value.jammatTime ?? "-"}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            NamazTimingScreen(userId: FirebaseAuth.instance.currentUser!.uid),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackBackground,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(AppStrings.getString('jummaTimings', currentLocale)),
                    ],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 140,
                      child: JummaTimingTable(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackBackground,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [TyperAnimatedText(AppStrings.getString('sunsetTimings', currentLocale))],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SunsetTimingsTable(
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackBackground,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [TyperAnimatedText(AppStrings.getString('fastingTimes', currentLocale))],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SizedBox(
                      height: 120,
                      child: RamzanTimingsTable(
                        userId: FirebaseAuth.instance.currentUser!.uid,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackBackground,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [TyperAnimatedText(AppStrings.getString('eidTimings', currentLocale))],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            EidTimingsTable(userId: FirebaseAuth.instance.currentUser!.uid, eidType: 'eidUlFitr',),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackColor,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [TyperAnimatedText(AppStrings.getString('prohibitedTimes', currentLocale))],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ProhibitedTimeScreen(userId: FirebaseAuth.instance.currentUser!.uid,),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blackColor,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [TyperAnimatedText(AppStrings.getString('specialNamazTimes', currentLocale))],
                    isRepeatingAnimation: false,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SpecialNamazScreen(userId: FirebaseAuth.instance.currentUser!.uid,),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(AppStrings.getString('addHadiyah', currentLocale),style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,

              ),),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withAlpha(13),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ExpansionTile(

                    title: Text(
                      AppStrings.getString('hadiya', currentLocale),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 8,
                    ),
                    children: hadiyaList.isEmpty
                        ? [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppStrings.getString('noHadiyaData', currentLocale),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      // Show add form when no hadiya exists
                      HadiyaBankDetailsForm(),
                    ]
                        : hadiyaList.map((hadiya) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              hadiya.type,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HadiyaDetailScreen(hadiya: hadiya),
                                ),
                              );
                            },
                          ),
                          Divider(
                            thickness: 1,
                            color: AppColors.blackColor,
                          ),
                        ],
                      );
                    }).toList(),
                  ),

                  // Show add form button when hadiya exists but user wants to add more
                  if (hadiyaList.isNotEmpty && hadiyaList.length < 2) // Assuming max 2 types (Masjid & Maulana)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          _showHadiyaForm(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppStrings.getString('addMoreHadiya', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20,),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                height: 60,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                        leading: Icon(
                          Icons.mosque,
                          color: AppColors.mainColor,
                        ),
                        title: Text(
                          AppStrings.getString('masjidAnnouncements', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackBackground,
                          ),
                        ),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminGeneralAnnouncementScreen()))
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}