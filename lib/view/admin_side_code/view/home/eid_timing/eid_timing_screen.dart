import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/models/eid_timings_model.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';

class EidTimingsTable extends StatefulWidget {
  final String userId;
  final String eidType; // "eidUlFitr" or "eidUlAzha"

  const EidTimingsTable({
    super.key,
    required this.userId,
    required this.eidType,
  });

  @override
  State<EidTimingsTable> createState() => _EidTimingsTableState();
}

class _EidTimingsTableState extends State<EidTimingsTable> {
  late final Stream<EidTiming> _eidStream;
  late SubAdminTimingsProvider _provider;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<SubAdminTimingsProvider>();
    _eidStream = _provider.streamEidTimings(widget.userId, widget.eidType);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final notSetText = AppStrings.getString('notSet', currentLocale);

    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
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
      child: StreamBuilder<EidTiming>(
        stream: _eidStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.mainColor,
              ),
            );
          }

          final eid = snapshot.data!;

          return Table(
            columnWidths: const {
              0: FlexColumnWidth(2), // Eid
              1: FlexColumnWidth(2), // Timings
              2: FlexColumnWidth(1.5), // Action
            },
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                children: [
                  _tableHeader(AppStrings.getString('eid', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('timings', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('action', currentLocale), currentLocale),
                ],
              ),
              TableRow(
                children: [
                  _tableCell(AppStrings.getString('jamaat1', currentLocale), currentLocale),
                  _tableCell(eid.jammat1.isNotEmpty ? eid.jammat1 : notSetText, currentLocale),
                  _actionCell("jammat1", eid, currentLocale),
                ],
              ),
              TableRow(
                children: [
                  _tableCell(AppStrings.getString('jamaat2', currentLocale), currentLocale),
                  _tableCell(eid.jammat2.isNotEmpty ? eid.jammat2 : notSetText, currentLocale),
                  _actionCell("jammat2", eid, currentLocale),
                ],
              ),
            ],
          );
        },
      ),
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

  Widget _tableCell(String text, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final displayText = text.isNotEmpty && text != "Not set" ? text : notSetText;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        displayText,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: displayText == notSetText ? Colors.grey : AppColors.mainColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _actionCell(String fieldKey, EidTiming eid, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = fieldKey == "jammat1"
        ? eid.jammat1.isNotEmpty && eid.jammat1 != "Not set" && eid.jammat1 != notSetText
        : eid.jammat2.isNotEmpty && eid.jammat2 != "Not set" && eid.jammat2 != notSetText;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: const Icon(Icons.edit, color: AppColors.backgroundColor1, size: 18),
            onTap: () => _showEditDialog(fieldKey, eid, currentLocale),
          ),
          const SizedBox(width: 10),
          if (hasData)
            InkWell(
              child: const Icon(Icons.delete, color: Colors.red, size: 18),
              onTap: () => _showDeleteDialog(fieldKey, eid, currentLocale),
            ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(String fieldKey, EidTiming eid, String currentLocale) async {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final TextEditingController timeController = TextEditingController(
      text: (fieldKey == "jammat1" ? eid.jammat1 : eid.jammat2) == notSetText ? '' :
      (fieldKey == "jammat1" ? eid.jammat1 : eid.jammat2),
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('edit', currentLocale)} ${fieldKey == 'jammat1' ? AppStrings.getString('jamaat1', currentLocale) : AppStrings.getString('jamaat2', currentLocale)} ${AppStrings.getString('time', currentLocale)}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          content: TextFormField(
            controller: timeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: AppStrings.getString('selectTime', currentLocale),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey),
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
                final updatedTime = timeController.text.trim();

                await _provider.addEidTiming(
                  userId: widget.userId,
                  jammat1: fieldKey == "jammat1" ? (updatedTime.isEmpty ? notSetText : updatedTime) : eid.jammat1,
                  jammat2: fieldKey == "jammat2" ? (updatedTime.isEmpty ? notSetText : updatedTime) : eid.jammat2,
                );

                Navigator.pop(context);
              },
              child: Text(
                AppStrings.getString('update', currentLocale),
                style: GoogleFonts.poppins(
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

  void _showDeleteDialog(String fieldKey, EidTiming eid, String currentLocale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('delete', currentLocale)} ${fieldKey == 'jammat1' ? AppStrings.getString('jamaat1', currentLocale) : AppStrings.getString('jamaat2', currentLocale)} ${AppStrings.getString('time', currentLocale)}",
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
                await _provider.deleteEidTiming(
                  userId: widget.userId,
                  eidType: widget.eidType,
                  fieldKey: fieldKey,
                );
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
}