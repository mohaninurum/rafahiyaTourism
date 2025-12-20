import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/subAdminProvider/sub-admin_sunset_timing_provider.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../../data/utils/circular_indicator_spinkit.dart';

class SunsetTimingsTable extends StatefulWidget {
  final String userId;

  const SunsetTimingsTable({super.key, required this.userId});

  @override
  State<SunsetTimingsTable> createState() => _SunsetTimingsTableState();
}

class _SunsetTimingsTableState extends State<SunsetTimingsTable> {
  late final SSunsetTimingProvider _sunsetProvider;
  late final SubAdminTimingsProvider provider;
  Map<String, String>? _cachedTimings;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sunsetProvider = Provider.of<SSunsetTimingProvider>(
      context,
      listen: false,
    );
    provider = Provider.of<SubAdminTimingsProvider>(
      context,
      listen: false,
    );
    _cachedTimings = _sunsetProvider.getCachedSunsetTimings(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return StreamBuilder<Map<String, String>>(
      stream: _sunsetProvider.getSunsetTimingsStream(widget.userId),
      initialData: _cachedTimings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData &&
            _cachedTimings == null) {
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.mainColor,
              spinKitType: SpinKitType.chasingDots,
            ),
          );
        }

        final notSetText = AppStrings.getString('notSet', currentLocale);
        final timings = snapshot.data ??
            _cachedTimings ??
            {
              'tuluTime': notSetText,
              'gurubTime': notSetText,
              'zawalTime': notSetText
            };
        _cachedTimings = timings; // Update cache

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                children: [
                  _tableHeader(AppStrings.getString('salah', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('timing', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('action', currentLocale), currentLocale),
                ],
              ),
              _sunsetTimingRow(
                _getFieldName("tuluTime", currentLocale),
                timings['tuluTime'] ?? notSetText,
                "tuluTime",
                currentLocale,
              ),
              _sunsetTimingRow(
                _getFieldName("gurubTime", currentLocale),
                timings['gurubTime'] ?? notSetText,
                "gurubTime",
                currentLocale,
              ),
              _sunsetTimingRow(
                _getFieldName("zawalTime", currentLocale),
                timings['zawalTime'] ?? notSetText,
                "zawalTime",
                currentLocale,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tableHeader(String title, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _sunsetTimingRow(String salah, String timing, String fieldKey, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = timing != notSetText && timing.isNotEmpty && timing != '';

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            salah,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            timing,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: timing == notSetText ? Colors.grey : AppColors.mainColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                child: const Icon(Icons.edit, color: AppColors.backgroundColor1, size: 18),
                onTap: () {
                  _showEditDialog(fieldKey, timing, currentLocale);
                },
              ),
              const SizedBox(width: 8),
              if (hasData)
                InkWell(
                  child: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onTap: () {
                    _showDeleteDialog(fieldKey, salah, currentLocale);
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(String fieldKey, String currentValue, String currentLocale) async {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final TextEditingController timeController = TextEditingController(
      text: currentValue == notSetText ? '' : currentValue,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('edit', currentLocale)} ${_getFieldName(fieldKey, currentLocale)}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: timeController,
                readOnly: true,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: AppStrings.getString('selectTime', currentLocale),
                  labelStyle: GoogleFonts.poppins(fontSize: 12),
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    timeController.text = picked.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                foregroundColor: AppColors.blackColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                AppStrings.getString('update', currentLocale),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor
                ),
              ),
              onPressed: () async {
                final updatedTime = timeController.text.trim();
                final timings = _cachedTimings ?? {};

                await provider.addSunsetTiming(
                  tuluTime: fieldKey == "tuluTime"
                      ? (updatedTime.isEmpty ? notSetText : updatedTime)
                      : (timings['tuluTime'] ?? notSetText),
                  gurubTime: fieldKey == "gurubTime"
                      ? (updatedTime.isEmpty ? notSetText : updatedTime)
                      : (timings['gurubTime'] ?? notSetText),
                  zawalTime: fieldKey == "zawalTime"
                      ? (updatedTime.isEmpty ? notSetText : updatedTime)
                      : (timings['zawalTime'] ?? notSetText),
                  userId: widget.userId,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String fieldKey, String salahName, String currentLocale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('delete', currentLocale)} $salahName ${AppStrings.getString('timing', currentLocale)}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          content: Text(
            "${AppStrings.getString('confirmDeleteMessage', currentLocale)} ${AppStrings.getString('thisWillSetToNotSet', currentLocale)}",
            style: GoogleFonts.poppins(fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 12,
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
                final timings = _cachedTimings ?? {};

                await provider.deleteAllSunsetTimings(widget.userId);
                Navigator.pop(ctx);
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getFieldName(String fieldKey, String currentLocale) {
    switch (fieldKey) {
      case "tuluTime":
        return AppStrings.getString('tulu', currentLocale);
      case "gurubTime":
        return AppStrings.getString('gurub', currentLocale);
      case "zawalTime":
        return AppStrings.getString('zawal', currentLocale);
      default:
        return fieldKey;
    }
  }
}