import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';

class JumaNamazInput extends StatefulWidget {
  final String namazName;
  final String imamId;

  const JumaNamazInput({
    super.key,
    required this.namazName,
    required this.imamId,
  });

  @override
  State<JumaNamazInput> createState() => _JumaNamazInputState();
}

class _JumaNamazInputState extends State<JumaNamazInput> {
  final TextEditingController _azaanController = TextEditingController();
  final TextEditingController _khutbaController = TextEditingController();
  final TextEditingController _jammatController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<SubAdminTimingsProvider>(
        context,
        listen: false,
      ).listenToJummaTiming(widget.namazName, widget.imamId);
    });
  }

  Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  String clean(String value) {
    return value
        .replaceAll(RegExp(r'[\u202F\u00A0]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _saveTimings(BuildContext context) async {
    final currentLocale = _getCurrentLocale(context);

    // ✅ Modified Validation - At least Azaan and Jamat times are required
    if (_azaanController.text.isEmpty || _jammatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getString('azaanJamatRequired', currentLocale))),
      );
      return;
    }

    try {
      await Provider.of<SubAdminTimingsProvider>(
        context,
        listen: false,
      ).addJummaNamazTime(
        namazName: widget.namazName,
        azanTime: clean(_azaanController.text),
        khutbaTime:
        _khutbaController.text.isEmpty
            ? "" // Send empty string if not filled
            : clean(_khutbaController.text),
        jammatTime: clean(_jammatController.text),
        imamId: widget.imamId,
      );

      _azaanController.clear();
      _khutbaController.clear();
      _jammatController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getJummaName(widget.namazName, currentLocale)} ${AppStrings.getString('timingsSavedSuccessfully', currentLocale)}'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.getString('failedToSaveTimings', currentLocale)}: ${e.toString()}')),
      );
    }
  }

  String _getJummaName(String namazKey, String currentLocale) {
    switch (namazKey) {
      case 'jumajammat1':
        return AppStrings.getString('jamaat1', currentLocale);
      case 'jumajammat2':
        return AppStrings.getString('jamaat2', currentLocale);
      default:
        return namazKey;
    }
  }

  @override
  void dispose() {
    _azaanController.dispose();
    _khutbaController.dispose();
    _jammatController.dispose();
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 0,
                ),
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
    final provider = context.watch<SubAdminTimingsProvider>();
    final isLoading = provider.isLoadingNamaz(widget.namazName);
    final exists = provider.jummaExists(widget.namazName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getJummaName(widget.namazName, currentLocale),
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
              _buildTimeField(AppStrings.getString('khutba', currentLocale), _khutbaController, currentLocale),
              _buildTimeField(AppStrings.getString('jamat', currentLocale), _jammatController, currentLocale),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              (isLoading || exists) ? null : () => _saveTimings(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                minimumSize: const Size(double.infinity, 40),
                disabledBackgroundColor: Colors.grey,
              ),
              child:
              isLoading
                  ? CustomCircularProgressIndicator(
                color: AppColors.mainColor,
                spinKitType: SpinKitType.chasingDots,
              )
                  : Text(
                exists
                    ? '${_getJummaName(widget.namazName, currentLocale)} ${AppStrings.getString('alreadyAdded', currentLocale)}'
                    : '${AppStrings.getString('save', currentLocale)} ${_getJummaName(widget.namazName, currentLocale)} ${AppStrings.getString('timings', currentLocale)}',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}