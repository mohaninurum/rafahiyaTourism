

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../../../../const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../../data/utils/circular_indicator_spinkit.dart';

class NamazTimingScreen extends StatefulWidget {
  final String userId;

  const NamazTimingScreen({super.key, required this.userId});

  @override
  State<NamazTimingScreen> createState() => _NamazTimingScreenState();
}

class _NamazTimingScreenState extends State<NamazTimingScreen> {
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

      if (cleaned.isEmpty || cleaned == 'Not set' || cleaned.toLowerCase() == 'not set') {
        return const TimeOfDay(hour: 23, minute: 59); // Far future time
      }

      // Try multiple time formats
      TimeOfDay? timeOfDay;

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

        // Format 3: Try parsing with space-separated AM/PM
        if (timeOfDay == null) {
          final match12Hour = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM|am|pm)$', caseSensitive: false).firstMatch(cleaned);
          if (match12Hour != null) {
            var hour = int.parse(match12Hour.group(1)!);
            final minute = int.parse(match12Hour.group(2)!);
            final period = match12Hour.group(3)!.toUpperCase();

            if (period == 'PM' && hour != 12) {
              hour += 12;
            } else if (period == 'AM' && hour == 12) {
              hour = 0;
            }
            if (hour == 24) hour = 0; // Handle midnight case

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

  String? getCurrentSalah(Map<String, Map<String, String>> timings) {
    final now = TimeOfDay.fromDateTime(_currentTime);
    int nowInMinutes = now.hour * 60 + now.minute;

    // Define salah order for the day
    final salahOrder = ['fajr', 'duhur', 'asr', 'magrib', 'isha'];

    // Check each salah to see if current time is between its azaan and akhir times
    for (var salah in salahOrder) {
      final timing = timings[salah];
      if (timing != null &&
          timing['azaan'] != null &&
          timing['akhir'] != null &&
          timing['azaan']!.isNotEmpty &&
          timing['akhir']!.isNotEmpty &&
          timing['azaan']!.toLowerCase() != 'not set' &&
          timing['akhir']!.toLowerCase() != 'not set') {

        final azaanTime = _parseTime(timing['azaan']!);
        final akhirTime = _parseTime(timing['akhir']!);

        if (_isBetweenTimes(azaanTime, akhirTime)) {
          return salah;
        }
      }
    }

    return null;
  }

  void _debugTimings(Map<String, Map<String, String>> timings) {
    debugPrint('=== DEBUG TIMINGS ===');
    debugPrint('Current Time: ${TimeOfDay.fromDateTime(_currentTime)}');

    final salahOrder = ['fajr', 'duhur', 'asr', 'magrib', 'isha'];
    for (var salah in salahOrder) {
      final timing = timings[salah];
      if (timing != null && timing['azaan'] != null && timing['akhir'] != null) {
        final azaanTime = _parseTime(timing['azaan']!);
        final akhirTime = _parseTime(timing['akhir']!);
        final isCurrent = getCurrentSalah(timings) == salah;
        debugPrint('$salah: Azaan: ${timing['azaan']} -> ${azaanTime} | Akhir: ${timing['akhir']} -> ${akhirTime} | Is Current: $isCurrent');
      }
    }

    final currentSalah = getCurrentSalah(timings);
    debugPrint('Current Salah: $currentSalah');
    debugPrint('=====================');
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final timingsProvider = Provider.of<SubAdminTimingsProvider>(context, listen: false);
    final cachedData = timingsProvider.getCachedNamazTimings(widget.userId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: DefaultTextStyle(
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.blackBackground,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(AppStrings.getString('namazTimings', currentLocale))
              ],
              isRepeatingAnimation: false,
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: StreamBuilder<Map<String, Map<String, String>>>(
            stream: timingsProvider.getNamazTiming(widget.userId),
            initialData: cachedData,
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};

              if (snapshot.connectionState == ConnectionState.waiting && cachedData == null) {
                return Center(
                  child: CustomCircularProgressIndicator(
                    color: AppColors.mainColor,
                    spinKitType: SpinKitType.chasingDots,
                  ),
                );
              }

              // Debug the timings
              _debugTimings(data);

              final salahOrder = ['fajr', 'duhur', 'asr', 'magrib', 'isha'];
              final currentSalah = getCurrentSalah(data);

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Table(
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                      children: [
                        _tableHeader(AppStrings.getString('salah', currentLocale), currentLocale),
                        _tableHeader(AppStrings.getString('azaan', currentLocale), currentLocale),
                        _tableHeader(AppStrings.getString('jamat', currentLocale), currentLocale),
                        _tableHeader(AppStrings.getString('awwal', currentLocale), currentLocale),
                        _tableHeader(AppStrings.getString('akhir', currentLocale), currentLocale),
                        _tableHeader(AppStrings.getString('actions', currentLocale), currentLocale),
                      ],
                    ),
                    ...salahOrder.map((salah) {
                      final timing = data[salah] ?? {};
                      final isCurrent = currentSalah == salah;

                      return _namazRow(
                        context,
                        salah,
                        _getSalahName(salah, currentLocale),
                        timing['azaan'] ?? AppStrings.getString('notSet', currentLocale),
                        timing['jamaat'] ?? AppStrings.getString('notSet', currentLocale),
                        timing['awwal'] ?? AppStrings.getString('notSet', currentLocale),
                        timing['akhir'] ?? AppStrings.getString('notSet', currentLocale),
                        currentLocale,
                        isCurrent: isCurrent,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  TableRow _namazRow(
      BuildContext context,
      String salahKey,
      String name,
      String azaan,
      String jamaat,
      String awwal,
      String akhir,
      String currentLocale, {
        required bool isCurrent,
      }) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = azaan != notSetText || jamaat != notSetText || awwal != notSetText || akhir != notSetText;

    return TableRow(
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.mainColor.withOpacity(0.8)
            : Colors.grey.shade100,
      ),
      children: [
        _tableCell(
          name,
          currentLocale,
          isCurrent: isCurrent,
          isSalahName: true,
        ),
        _tableCell(azaan, currentLocale, colored: true, isCurrent: isCurrent),
        _tableCell(jamaat, currentLocale, colored: true, isCurrent: isCurrent),
        _tableCell(awwal, currentLocale, colored: true, isCurrent: isCurrent),
        _tableCell(akhir, currentLocale, colored: true, isCurrent: isCurrent),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: Icon(
                    Icons.edit,
                    color: isCurrent ? Colors.white : AppColors.backgroundColor1,
                    size: 18
                ),
                onTap: () {
                  _showUpdateDialog(context, salahKey, name, azaan, jamaat, awwal, akhir, currentLocale);
                },
              ),
              const SizedBox(width: 10),
              if (hasData)
                InkWell(
                  child: Icon(
                      Icons.delete,
                      color: isCurrent ? Colors.white : Colors.red,
                      size: 18
                  ),
                  onTap: () {
                    _showDeleteDialog(context, salahKey, name, currentLocale);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableHeader(String title, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(
      String text,
      String currentLocale, {
        bool colored = false,
        bool isCurrent = false,
        bool isSalahName = false,
      }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
          color: isCurrent
              ? Colors.white
              : (colored ? AppColors.mainColor : Colors.black),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _showUpdateDialog(
      BuildContext context,
      String salahKey,
      String salahName,
      String azaan,
      String jamaat,
      String awwal,
      String akhir,
      String currentLocale,
      ) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final azaanController = TextEditingController(text: azaan == notSetText ? '' : azaan);
    final jammatController = TextEditingController(text: jamaat == notSetText ? '' : jamaat);
    final awwalController = TextEditingController(text: awwal == notSetText ? '' : awwal);
    final akhirController = TextEditingController(text: akhir == notSetText ? '' : akhir);

    Future<void> _pickTime(TextEditingController controller) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        controller.text = picked.format(context);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('update', currentLocale)} $salahName ${AppStrings.getString('timings', currentLocale)}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mainColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeField(AppStrings.getString('azaan', currentLocale), azaanController, () => _pickTime(azaanController), currentLocale),
              _timeField(AppStrings.getString('jamat', currentLocale), jammatController, () => _pickTime(jammatController), currentLocale),
              _timeField(AppStrings.getString('awwal', currentLocale), awwalController, () => _pickTime(awwalController), currentLocale),
              _timeField(AppStrings.getString('akhir', currentLocale), akhirController, () => _pickTime(akhirController), currentLocale),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.blackColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                print("time >>>${azaanController.text}");
                final provider = Provider.of<SubAdminTimingsProvider>(context, listen: false);
                await provider.saveNamazTiming(
                  namazName: salahKey,
                  azaanTime: azaanController.text.isEmpty ? notSetText : azaanController.text,
                  jammatTime: jammatController.text.isEmpty ? notSetText : jammatController.text,
                  awwalTime: awwalController.text.isEmpty ? notSetText : awwalController.text,
                  akhirTime: akhirController.text.isEmpty ? notSetText : akhirController.text,
                  imamId: widget.userId,
                );
                Navigator.pop(ctx);
              },
              child: Text(
                AppStrings.getString('save', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String salahKey, String salahName, String currentLocale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('delete', currentLocale)} $salahName ${AppStrings.getString('timings', currentLocale)}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          content: Text(
            "${AppStrings.getString('confirmDeleteMessage', currentLocale)} ${AppStrings.getString('thisActionCannotBeUndone', currentLocale)}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                final provider = Provider.of<SubAdminTimingsProvider>(context, listen: false);
                await provider.deleteNamazTiming(widget.userId, salahKey);
                Navigator.pop(ctx);
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _timeField(String label, TextEditingController controller, VoidCallback onTap, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  String _getSalahName(String salahKey, String currentLocale) {
    switch (salahKey) {
      case 'fajr':
        return AppStrings.getString('fajr', currentLocale);
      case 'duhur':
        return AppStrings.getString('duhur', currentLocale);
      case 'asr':
        return AppStrings.getString('asr', currentLocale);
      case 'magrib':
        return AppStrings.getString('magrib', currentLocale);
      case 'isha':
        return AppStrings.getString('isha', currentLocale);
      default:
        return _capitalize(salahKey);
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }
}