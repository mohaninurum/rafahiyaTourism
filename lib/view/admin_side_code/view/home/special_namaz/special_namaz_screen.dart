import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/models/special_namaz.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';

class SpecialNamazScreen extends StatefulWidget {
  final String userId;

  const SpecialNamazScreen({super.key, required this.userId});

  @override
  State<SpecialNamazScreen> createState() => _SpecialNamazScreenState();
}

class _SpecialNamazScreenState extends State<SpecialNamazScreen> {
  late final Stream<SpecialNamaz> _namazStream;
  late SubAdminTimingsProvider _provider;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<SubAdminTimingsProvider>();
    _namazStream = _provider.streamSpecialNamaz(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final notSetText = AppStrings.getString('notSet', currentLocale);

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(12),
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
      child: StreamBuilder<SpecialNamaz>(
        stream: _namazStream,
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.mainColor,
              ),
            );
          }

          // Handle error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppStrings.getString('errorLoadingData', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            );
          }

          // Get data or use default empty values
          final namaz = snapshot.data ?? SpecialNamaz(
            namaz1Name: '',
            namaz1Time: '',
            namaz2Name: '',
            namaz2Time: '',
            namaz3Name: '',
            namaz3Time: '',
            imamId: '',
          );

          return Column(
            children: [
              // Always show the table, even with empty data
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                },
                border: TableBorder.all(color: Colors.grey.shade300),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                    children: [
                      _tableHeader(AppStrings.getString('namazName', currentLocale), currentLocale),
                      _tableHeader(AppStrings.getString('timing', currentLocale), currentLocale),
                      _tableHeader(AppStrings.getString('action', currentLocale), currentLocale),
                    ],
                  ),
                  _buildRow("namaz1Name", "namaz1Time", namaz.namaz1Name, namaz.namaz1Time, currentLocale),
                  _buildRow("namaz2Name", "namaz2Time", namaz.namaz2Name, namaz.namaz2Time, currentLocale),
                  _buildRow("namaz3Name", "namaz3Time", namaz.namaz3Name, namaz.namaz3Time, currentLocale),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  // Helper method to check if any data exists
  bool _hasAnyData(SpecialNamaz namaz) {
    return namaz.namaz1Name.isNotEmpty ||
        namaz.namaz1Time.isNotEmpty ||
        namaz.namaz2Name.isNotEmpty ||
        namaz.namaz2Time.isNotEmpty ||
        namaz.namaz3Name.isNotEmpty ||
        namaz.namaz3Time.isNotEmpty;
  }

  TableRow _buildRow(String nameField, String timeField, String name, String time, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final displayName = name.isEmpty ? notSetText : name;
    final displayTime = time.isEmpty ? notSetText : time;
    final hasData = name.isNotEmpty || time.isNotEmpty;

    return TableRow(
      decoration: hasData ? null : BoxDecoration(color: Colors.grey.shade100),
      children: [
        _tableCell(displayName, currentLocale),
        _tableCell(displayTime, currentLocale),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Edit Button - always show
              InkWell(
                onTap: () {
                  _showEditDialog(nameField, timeField, name, time, currentLocale);
                },
                child: Icon(
                    Icons.edit,
                    color: AppColors.backgroundColor1,
                    size: 18
                ),
              ),
              const SizedBox(width: 8),
              // Delete Button - only show when there's data
              if (hasData)
                InkWell(
                  child: const Icon(Icons.delete, color: Colors.red, size: 18),
                  onTap: () {
                    _showDeleteConfirmation(nameField, timeField, name, currentLocale);
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
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: text == notSetText ? Colors.grey : AppColors.mainColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// ✅ Edit Dialog
  void _showEditDialog(String nameField, String timeField, String currentName, String currentTime, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final nameController = TextEditingController(text: currentName.isEmpty || currentName == notSetText ? '' : currentName);
    final timeController = TextEditingController(text: currentTime.isEmpty || currentTime == notSetText ? '' : currentTime);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          AppStrings.getString('editSpecialNamaz', currentLocale),
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
              controller: nameController,
              decoration: InputDecoration(
                labelText: AppStrings.getString('namazName', currentLocale),
                hintText: AppStrings.getString('enterNamazName', currentLocale),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: timeController,
              readOnly: true,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  timeController.text = picked.format(context);
                }
              },
              decoration: InputDecoration(
                labelText: AppStrings.getString('namazTime', currentLocale),
                hintText: AppStrings.getString('selectTime', currentLocale),
                suffixIcon: const Icon(Icons.access_time),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              AppStrings.getString('cancel', currentLocale),
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              foregroundColor: AppColors.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              AppStrings.getString('update', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () async {
              if (nameController.text.isEmpty || timeController.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppStrings.getString('fillBothFields', currentLocale),
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _provider.updateSpecialNamaz(
                userId: widget.userId,
                nameField: nameField,
                timeField: timeField,
                newName: nameController.text,
                newTime: timeController.text,
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Delete Confirmation Dialog for single row
  void _showDeleteConfirmation(String nameField, String timeField, String namazName, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final displayName = namazName.isEmpty || namazName == notSetText ?
    AppStrings.getString('thisNamaz', currentLocale) : namazName;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          AppStrings.getString('deleteNamaz', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        content: Text(
          "${AppStrings.getString('confirmDeleteMessage', currentLocale)} $displayName?",
          style: GoogleFonts.poppins(fontSize: 12),
        ),
        actions: [
          TextButton(
            child: Text(
              AppStrings.getString('cancel', currentLocale),
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppStrings.getString('delete', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () async {
              await _provider.deleteSpecialNamaz(
                userId: widget.userId,
                nameField: nameField,
                timeField: timeField,
              );
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.getString('namazDeletedSuccessfully', currentLocale),
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}