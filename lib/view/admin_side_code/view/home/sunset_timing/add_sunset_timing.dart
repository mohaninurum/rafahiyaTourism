import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../../../../const/error_handler.dart';
import '../../../../../const/toast_helper.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../../data/utils/circular_indicator_spinkit.dart';

class AddSunsetTiming extends StatefulWidget {
  const AddSunsetTiming({super.key});

  @override
  State<AddSunsetTiming> createState() => _AddSunsetTimingState();
}

class _AddSunsetTimingState extends State<AddSunsetTiming> {
  final TextEditingController tuluTimeController = TextEditingController();
  final TextEditingController gurubTimeController = TextEditingController();
  final TextEditingController zawalTimeController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      controller.text = picked.format(context);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<SubAdminTimingsProvider>(context, listen: false)
          .listenToSunsetTiming(userId);
    });
  }

  @override
  void dispose() {
    tuluTimeController.dispose();
    gurubTimeController.dispose();
    zawalTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = context.watch<SubAdminTimingsProvider>();
    final isLoading = provider.isLoading;
    final exists = provider.sunsetExists;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          AppStrings.getString('sunsetTiming', currentLocale),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        children: [
          _buildTimeRow(AppStrings.getString('tulu', currentLocale), tuluTimeController, currentLocale),
          const Divider(thickness: 1),
          _buildTimeRow(AppStrings.getString('gurub', currentLocale), gurubTimeController, currentLocale),
          const Divider(thickness: 1),
          _buildTimeRow(AppStrings.getString('zawal', currentLocale), zawalTimeController, currentLocale),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: (isLoading || exists)
                ? null
                : () async {
              if (tuluTimeController.text.isEmpty ||
                  gurubTimeController.text.isEmpty ||
                  zawalTimeController.text.isEmpty) {
                ToastHelper.show(AppStrings.getString('enterAllTimings', currentLocale));
                return;
              }

              try {
                await provider.addSunsetTiming(
                  tuluTime: tuluTimeController.text,
                  gurubTime: gurubTimeController.text,
                  zawalTime: zawalTimeController.text,
                  userId: FirebaseAuth.instance.currentUser!.uid,
                );

                ToastHelper.show(AppStrings.getString('sunsetTimingsSaved', currentLocale));

                tuluTimeController.clear();
                gurubTimeController.clear();
                zawalTimeController.clear();
              } catch (e) {
                ErrorHandler.showError(e);
              }
            },
            child: Container(
              height: 40,
              width: 200,
              decoration: BoxDecoration(
                color: exists ? Colors.grey : AppColors.mainColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isLoading
                    ? CustomCircularProgressIndicator(
                  size: 60,
                  color: AppColors.backgroundColor1,
                  spinKitType: SpinKitType.chasingDots,
                )
                    : Text(
                  exists ? AppStrings.getString('alreadySaved', currentLocale) : AppStrings.getString('save', currentLocale),
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteBackground,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, TextEditingController controller, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.blackBackground,
            ),
          ),
          SizedBox(
            width: 130,
            height: 35,
            child: TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 10),
              readOnly: true,
              onTap: () => _selectTime(context, controller),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
}