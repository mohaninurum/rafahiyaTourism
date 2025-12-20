import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../../data/utils/circular_indicator_spinkit.dart';

class JummaTimingTable extends StatefulWidget {
  final String userId;

  const JummaTimingTable({super.key, required this.userId});

  @override
  State<JummaTimingTable> createState() => _JummaTimingTableState();
}

class _JummaTimingTableState extends State<JummaTimingTable> {
  late final SubAdminTimingsProvider _timingsProvider;
  Map<String, String>? _cachedTimings;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timingsProvider = Provider.of<SubAdminTimingsProvider>(
      context,
      listen: false,
    );
    _cachedTimings = _timingsProvider.getCachedJummaTimings(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return StreamBuilder<Map<String, String>>(
      stream: _timingsProvider.getJummaTimingsStream(widget.userId),
      initialData: _cachedTimings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _cachedTimings == null) {
          return Center(
            child: CustomCircularProgressIndicator(
              color: AppColors.mainColor,
              spinKitType: SpinKitType.chasingDots,
            ),
          );
        }

        final timings = snapshot.data ?? {};
        _cachedTimings = timings;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
            },
            border: TableBorder.all(color: Colors.grey.shade300, width: 1.0),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                children: [
                  _tableHeader(AppStrings.getString('azaan', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('khutba', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('jamat', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('actions', currentLocale), currentLocale),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade100),
                children: [
                  _tableCell(timings['azaan1'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _tableCell(timings['khutba1'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _tableCell(timings['jamaat1'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _actionCell(
                    context,
                    namazKey: "jumaJammat1",
                    azaan: timings['azaan1'] ?? '',
                    khutba: timings['khutba1'] ?? '',
                    jamaat: timings['jamaat1'] ?? '',
                    currentLocale: currentLocale,
                  ),
                ],
              ),
              TableRow(
                decoration: BoxDecoration(color: Colors.grey.shade50),
                children: [
                  _tableCell(timings['azaan2'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _tableCell(timings['khutba2'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _tableCell(timings['jamaat2'] ?? AppStrings.getString('notSet', currentLocale), currentLocale, colored: true),
                  _actionCell(
                    context,
                    namazKey: "jumaJammat2",
                    azaan: timings['azaan2'] ?? '',
                    khutba: timings['khutba2'] ?? '',
                    jamaat: timings['jamaat2'] ?? '',
                    currentLocale: currentLocale,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionCell(
      BuildContext context, {
        required String namazKey,
        required String azaan,
        required String khutba,
        required String jamaat,
        required String currentLocale,
      }) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = azaan.isNotEmpty && azaan != notSetText ||
        khutba.isNotEmpty && khutba != notSetText ||
        jamaat.isNotEmpty && jamaat != notSetText;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: const Icon(Icons.edit, color: AppColors.backgroundColor1, size: 18),
            onTap: () {
              _showUpdateDialog(
                context,
                namazKey: namazKey,
                currentAzaan: azaan,
                currentKhutba: khutba,
                currentJamaat: jamaat,
                currentLocale: currentLocale,
              );
            },
          ),
          const SizedBox(width: 10),
          if (hasData)
            InkWell(
              child: const Icon(Icons.delete, color: Colors.red, size: 18),
              onTap: () {
                _showDeleteDialog(context, namazKey, currentLocale);
              },
            ),
        ],
      ),
    );
  }

  void _showUpdateDialog(
      BuildContext context, {
        required String namazKey,
        required String currentAzaan,
        required String currentKhutba,
        required String currentJamaat,
        required String currentLocale,
      }) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final azaanController = TextEditingController(text: currentAzaan == notSetText ? '' : currentAzaan);
    final khutbaController = TextEditingController(text: currentKhutba == notSetText ? '' : currentKhutba);
    final jamaatController = TextEditingController(text: currentJamaat == notSetText ? '' : currentJamaat);

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
            AppStrings.getString('updateJummaTiming', currentLocale),
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
              _timeField(AppStrings.getString('khutba', currentLocale), khutbaController, () => _pickTime(khutbaController), currentLocale),
              _timeField(AppStrings.getString('jamat', currentLocale), jamaatController, () => _pickTime(jamaatController), currentLocale),
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
                await _timingsProvider.saveJummaNamazTime(
                  namazName: namazKey,
                  azanTime: azaanController.text.isEmpty ? notSetText : azaanController.text,
                  khutbaTime: khutbaController.text.isEmpty ? notSetText : khutbaController.text,
                  jammatTime: jamaatController.text.isEmpty ? notSetText : jamaatController.text,
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

  void _showDeleteDialog(BuildContext context, String namazKey, String currentLocale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            AppStrings.getString('deleteJummaTiming', currentLocale),
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
                await _timingsProvider.deleteJummaTiming(widget.userId, namazKey);
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

  Widget _tableHeader(String title, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, String currentLocale, {bool colored = false}) {
    final displayText = text.isEmpty ? AppStrings.getString('notSet', currentLocale) : text;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        displayText,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: colored ? AppColors.mainColor : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}