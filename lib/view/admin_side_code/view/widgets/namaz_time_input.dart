import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';

class NamazTimeInput extends StatefulWidget {
  final String namazName;
  final String imamId;

  const NamazTimeInput({
    super.key,
    required this.namazName,
    required this.imamId,
  });

  @override
  State<NamazTimeInput> createState() => _NamazTimeInputState();
}

class _NamazTimeInputState extends State<NamazTimeInput> {
  final TextEditingController _azaanController = TextEditingController();
  final TextEditingController _jammatController = TextEditingController();
  final TextEditingController _awwalController = TextEditingController();
  final TextEditingController _akhirController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubAdminTimingsProvider>(context, listen: false)
          .listenToNamazTiming(widget.imamId, widget.namazName);
    });
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  Future<void> _saveTimings(BuildContext context) async {
    final currentLocale = _getCurrentLocale(context);

    if (_azaanController.text.isEmpty || _jammatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getString('azaanJammatRequired', currentLocale))),
      );
      return;
    }

    try {
      await Provider.of<SubAdminTimingsProvider>(context, listen: false)
          .addNamazTiming(
        namazName: widget.namazName,
        azaanTime: _azaanController.text,
        jammatTime: _jammatController.text,
        awwalTime: _awwalController.text.isEmpty ? null : _awwalController.text,
        akhirTime: _akhirController.text.isEmpty ? null : _akhirController.text,
        imamId: widget.imamId,
      );

      // Clear controllers after successful save
      _azaanController.clear();
      _jammatController.clear();
      _awwalController.clear();
      _akhirController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_getNamazName(widget.namazName, currentLocale)} ${AppStrings.getString('timingsSavedSuccessfully', currentLocale)}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.getString('failedToSaveTimings', currentLocale)}: ${e.toString()}')),
      );
    }
  }

  String _getNamazName(String namazKey, String currentLocale) {
    switch (namazKey) {
      case 'FAJR':
        return AppStrings.getString('fajr', currentLocale);
      case 'ZOHAR':
        return AppStrings.getString('zohar', currentLocale);
      case 'ASR':
        return AppStrings.getString('asr', currentLocale);
      case 'MAGRIB':
        return AppStrings.getString('magrib', currentLocale);
      case 'ISHA':
        return AppStrings.getString('isha', currentLocale);
      default:
        return namazKey;
    }
  }

  @override
  void dispose() {
    _azaanController.dispose();
    _jammatController.dispose();
    _awwalController.dispose();
    _akhirController.dispose();
    super.dispose();
  }

  Widget _buildTimeField(String label, TextEditingController controller, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.blackBackground,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            height: 35,
            child: TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 10),
              readOnly: true,
              onTap: () => _selectTime(context, controller),
              decoration: InputDecoration(
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final isLoading = context.select<SubAdminTimingsProvider, bool>(
          (provider) => provider.isLoadingNamaz(widget.namazName),
    );

    final isSaved = context.select<SubAdminTimingsProvider, bool>(
          (provider) => provider.isNamazSaved(widget.namazName),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getNamazName(widget.namazName, currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeField(AppStrings.getString('azaan', currentLocale), _azaanController, currentLocale),
              _buildTimeField(AppStrings.getString('jamat', currentLocale), _jammatController, currentLocale),
              _buildTimeField(AppStrings.getString('awwal', currentLocale), _awwalController, currentLocale),
              _buildTimeField(AppStrings.getString('akhir', currentLocale), _akhirController, currentLocale),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              (isLoading || isSaved) ? null : () => _saveTimings(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                minimumSize: const Size(double.infinity, 40),
                disabledBackgroundColor: Colors.grey,
              ),
              child: isLoading
                  ? CustomCircularProgressIndicator(
                color: AppColors.mainColor,
                spinKitType: SpinKitType.chasingDots,
              )
                  : Text(
                isSaved
                    ? '${_getNamazName(widget.namazName, currentLocale)} ${AppStrings.getString('alreadySaved', currentLocale)}'
                    : '${AppStrings.getString('save', currentLocale)} ${_getNamazName(widget.namazName, currentLocale)} ${AppStrings.getString('timings', currentLocale)}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}