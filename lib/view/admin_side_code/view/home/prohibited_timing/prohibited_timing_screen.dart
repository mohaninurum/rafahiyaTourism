import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/models/prohibited_time_model.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';

class ProhibitedTimeScreen extends StatefulWidget {
  final String userId;

  const ProhibitedTimeScreen({super.key, required this.userId});

  @override
  State<ProhibitedTimeScreen> createState() => _ProhibitedTimeScreenState();
}

class _ProhibitedTimeScreenState extends State<ProhibitedTimeScreen> {
  late final Stream<ProhibitedTime> _prohibitedStream;
  late SubAdminTimingsProvider _provider;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _provider = context.read<SubAdminTimingsProvider>();
    _prohibitedStream = _provider.streamProhibitedTiming(widget.userId);
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
      child: StreamBuilder<ProhibitedTime>(
        stream: _prohibitedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.mainColor,
              ),
            );
          }

          final prohibited = snapshot.data!;

          return Table(
            columnWidths: const {
              0: FlexColumnWidth(1), // Index
              1: FlexColumnWidth(2), // From
              2: FlexColumnWidth(2), // To
              3: FlexColumnWidth(1), // Edit Action
              4: FlexColumnWidth(1), // Delete Action
            },
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFEFEFEF)),
                children: [
                  _tableHeader(AppStrings.getString('no', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('from', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('to', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('edit', currentLocale), currentLocale),
                  _tableHeader(AppStrings.getString('delete', currentLocale), currentLocale),
                ],
              ),
              _buildRow("1", prohibited.time1From, prohibited.time1To, currentLocale),
              _buildRow("2", prohibited.time2From, prohibited.time2To, currentLocale),
              _buildRow("3", prohibited.time3From, prohibited.time3To, currentLocale),
              _buildRow("4", prohibited.time4From, prohibited.time4To, currentLocale),
            ],
          );
        },
      ),
    );
  }

  TableRow _buildRow(String index, String from, String to, String currentLocale) {
    return TableRow(
      children: [
        _tableCell(index, currentLocale),
        _tableCell(from, currentLocale),
        _tableCell(to, currentLocale),
        _editActionCell(index, from, to, currentLocale),
        _deleteActionCell(index, from, to, currentLocale),
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

  Widget _editActionCell(String index, String from, String to, String currentLocale) {
    return IconButton(
      icon: const Icon(Icons.edit, color: AppColors.backgroundColor1, size: 20),
      onPressed: () => _showEditDialog(index, from, to, currentLocale),
    );
  }

  Widget _deleteActionCell(String index, String from, String to, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = from.isNotEmpty && from != "Not set" && from != notSetText &&
        to.isNotEmpty && to != "Not set" && to != notSetText;

    return IconButton(
      icon: Icon(
          Icons.delete,
          color: hasData ? Colors.red : Colors.grey,
          size: 20
      ),
      onPressed: hasData ? () => _showDeleteDialog(index, from, to, currentLocale) : null,
    );
  }

  Future<void> _showEditDialog(String index, String from, String to, String currentLocale) async {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final TextEditingController fromController =
    TextEditingController(text: from == "Not set" || from == notSetText ? '' : from);
    final TextEditingController toController =
    TextEditingController(text: to == "Not set" || to == notSetText ? '' : to);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('edit', currentLocale)} ${AppStrings.getString('time', currentLocale)} $index",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _timePickerField(AppStrings.getString('from', currentLocale), fromController, currentLocale),
              const SizedBox(height: 10),
              _timePickerField(AppStrings.getString('to', currentLocale), toController, currentLocale),
            ],
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
                final updatedFrom = fromController.text.trim();
                final updatedTo = toController.text.trim();

                await _provider.updateProhibitedTime(
                  userId: widget.userId,
                  index: index,
                  from: updatedFrom.isEmpty ? notSetText : updatedFrom,
                  to: updatedTo.isEmpty ? notSetText : updatedTo,
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

  Future<void> _showDeleteDialog(String index, String from, String to, String currentLocale) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            "${AppStrings.getString('delete', currentLocale)} ${AppStrings.getString('time', currentLocale)} $index?",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          content: Text(
            "${AppStrings.getString('confirmDeleteMessage', currentLocale)}\n\n${AppStrings.getString('from', currentLocale)}: $from\n${AppStrings.getString('to', currentLocale)}: $to",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.blackColor,
            ),
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
                backgroundColor: Colors.red,
                foregroundColor: AppColors.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog first
                await _deleteProhibitedTime(index, currentLocale);
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProhibitedTime(String index, String currentLocale) async {
    try {
      await _provider.deleteProhibitedTime(
        userId: widget.userId,
        index: index,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            AppStrings.getString('prohibitedTimeDeleted', currentLocale),
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "${AppStrings.getString('errorDeletingProhibitedTime', currentLocale)}: $e",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _timePickerField(String label, TextEditingController controller, String currentLocale) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
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
          controller.text = picked.format(context);
        }
      },
    );
  }
}