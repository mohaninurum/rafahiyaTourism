import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../../../provider/locale_provider.dart';
import '../../../../../utils/language/app_strings.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';

class RamzanTimingsTable extends StatefulWidget {
  final String userId;

  const RamzanTimingsTable({super.key, required this.userId});

  @override
  State<RamzanTimingsTable> createState() => _RamzanTimingsTableState();
}

class _RamzanTimingsTableState extends State<RamzanTimingsTable> {
  late Stream<Map<String, dynamic>> _stream;
  late SubAdminTimingsProvider _provider;
  Map<String, dynamic>? _lastTimings;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<SubAdminTimingsProvider>(context, listen: false);
    _lastTimings = _convertToDynamicMap(_provider.getCachedRamzanTimings(widget.userId));
    _stream = _getEnhancedRamzanStream(widget.userId);
  }

  // Convert Map<String, String> to Map<String, dynamic>
  Map<String, dynamic>? _convertToDynamicMap(Map<String, String>? stringMap) {
    if (stringMap == null) return null;
    final currentLocale = _getCurrentLocale(context);
    final notSetText = AppStrings.getString('notSet', currentLocale);
    return {
      'sehrTime': stringMap['sehrTime'] ?? notSetText,
      'iftarTime': stringMap['iftarTime'] ?? notSetText,
      'lastUpdated': '',
    };
  }

  Stream<Map<String, dynamic>> _getEnhancedRamzanStream(String userId) {
    final currentLocale = _getCurrentLocale(context);
    final notSetText = AppStrings.getString('notSet', currentLocale);

    // Create a stream that combines both the timings and the lastUpdated field
    return FirebaseFirestore.instance
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('ramzan')
        .snapshots()
        .asyncMap<Map<String, dynamic>>((doc) {
      final data = doc.data() ?? {};
      final lastUpdated = data['lastUpdated'] as Timestamp?;

      String formattedDate = '';
      if (lastUpdated != null) {
        final date = lastUpdated.toDate();
        formattedDate = '${_getMonthName(date.month, currentLocale)} ${date.day}, ${date.year} ${AppStrings.getString('at', currentLocale)} ${_formatTime(date, currentLocale)}';
      }

      return {
        'sehrTime': (data['sehrTime'] as String?)?.trim() ?? notSetText,
        'iftarTime': (data['iftarTime'] as String?)?.trim() ?? notSetText,
        'lastUpdated': formattedDate,
      };
    }).handleError((error) {
      debugPrint('Ramzan timings stream error: $error');
      return _lastTimings ?? {
        'sehrTime': notSetText,
        'iftarTime': notSetText,
        'lastUpdated': '',
      };
    });
  }

  String _getMonthName(int month, String currentLocale) {
    if (currentLocale == 'hi') {
      const months = [
        'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
        'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
      ];
      return months[month - 1];
    } else if (currentLocale == 'ar') {
      const months = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return months[month - 1];
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return months[month - 1];
    }
  }

  String _formatTime(DateTime date, String currentLocale) {
    final hour = date.hour % 12;
    final hour12 = hour == 0 ? 12 : hour;
    final minute = date.minute.toString().padLeft(2, '0');

    String period;
    if (currentLocale == 'hi') {
      period = date.hour < 12 ? 'सुबह' : 'शाम';
    } else if (currentLocale == 'ar') {
      period = date.hour < 12 ? 'ص' : 'م';
    } else {
      period = date.hour < 12 ? 'AM' : 'PM';
    }

    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final notSetText = AppStrings.getString('notSet', currentLocale);

    return StreamBuilder<Map<String, dynamic>>(
      stream: _stream,
      initialData: _lastTimings,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _lastTimings ?? {
          'sehrTime': notSetText,
          'iftarTime': notSetText,
          'lastUpdated': ''
        };
        _lastTimings = data;

        final timings = {
          'sehrTime': data['sehrTime'] ?? notSetText,
          'iftarTime': data['iftarTime'] ?? notSetText,
        };

        final lastUpdated = data['lastUpdated'] ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastUpdated.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  '$lastUpdated',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Table - Always show it
            _buildTable(timings, currentLocale),
          ],
        );
      },
    );
  }

  Widget _buildTable(Map<String, dynamic> timings, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final hasData = (timings['sehrTime'] != notSetText && timings['sehrTime']!.toString().isNotEmpty) ||
        (timings['iftarTime'] != notSetText && timings['iftarTime']!.toString().isNotEmpty);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(1.5),
        },
        border: TableBorder.all(color: Colors.grey.shade400, width: 1.0),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade200),
            children: [
              _tableHeader(AppStrings.getString('sehr', currentLocale), currentLocale),
              _tableHeader(AppStrings.getString('iftar', currentLocale), currentLocale),
              _tableHeader(AppStrings.getString('action', currentLocale), currentLocale),
            ],
          ),
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              _timingCell(timings['sehrTime']?.toString() ?? notSetText, currentLocale),
              _timingCell(timings['iftarTime']?.toString() ?? notSetText, currentLocale),
              _actionCell(timings, hasData, currentLocale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _timingCell(String time, String currentLocale) {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        time,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: time == notSetText ? Colors.grey : AppColors.mainColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _actionCell(Map<String, dynamic> timings, bool hasData, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            child: const Icon(Icons.edit, color: AppColors.backgroundColor1, size: 18),
            onTap: () => _showEditDialog(timings, currentLocale),
          ),
          const SizedBox(width: 10),
          if (hasData)
            InkWell(
              child: const Icon(Icons.delete, color: Colors.red, size: 18),
              onTap: () => _showDeleteDialog(currentLocale),
            ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(Map<String, dynamic> timings, String currentLocale) async {
    final notSetText = AppStrings.getString('notSet', currentLocale);
    final TextEditingController sehrController = TextEditingController(
        text: timings['sehrTime'] == notSetText ? '' : timings['sehrTime'] ?? ''
    );
    final TextEditingController iftarController = TextEditingController(
        text: timings['iftarTime'] == notSetText ? '' : timings['iftarTime'] ?? ''
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            AppStrings.getString('editRamzanTimings', currentLocale),
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
                controller: sehrController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('sehrTime', currentLocale),
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
                    sehrController.text = picked.format(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: iftarController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('iftarTime', currentLocale),
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
                    iftarController.text = picked.format(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                  AppStrings.getString('cancel', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.grey)
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
                await _provider.addRamzanTiming(
                  sehrTime: sehrController.text.isEmpty ? notSetText : sehrController.text.trim(),
                  iftarTime: iftarController.text.isEmpty ? notSetText : iftarController.text.trim(),
                  mosqueId: widget.userId,
                );
                Navigator.pop(context);
              },
              child: Text(
                AppStrings.getString('update', currentLocale),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: AppColors.whiteColor
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String currentLocale) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            AppStrings.getString('deleteRamzanTimings', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          content: Text(
            AppStrings.getString('deleteRamzanTimingsMessage', currentLocale),
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
                await _provider.deleteRamzanTimings(widget.userId);
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