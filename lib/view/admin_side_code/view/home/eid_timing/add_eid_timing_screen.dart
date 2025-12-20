import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../../../../const/error_handler.dart';
import '../../../../../const/toast_helper.dart';
import '../../../admin_bottom_navigationbar.dart';
import '../../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../../../data/utils/circular_indicator_spinkit.dart';

class AddEidTimingScreen extends StatefulWidget {
  const AddEidTimingScreen({super.key});

  @override
  State<AddEidTimingScreen> createState() => _AddEidTimingScreenState();
}

class _AddEidTimingScreenState extends State<AddEidTimingScreen> {
  final TextEditingController eidUlFitrJammat1Controller =
  TextEditingController();
  final TextEditingController eidUlFitrJammat2Controller =
  TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SubAdminTimingsProvider>(
      context,
      listen: false,
    );
    final userId = FirebaseAuth.instance.currentUser!.uid;
    provider.listenEidTiming(userId, "eidUlFitr");
  }

  @override
  void dispose() {
    eidUlFitrJammat1Controller.dispose();
    eidUlFitrJammat2Controller.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
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
        initiallyExpanded: true,
        title: Text(
          AppStrings.getString('eidTiming', currentLocale),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 8,
        ),
        children: [
          // Jammat 1
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.getString('jamaat1', currentLocale),
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
                    controller: eidUlFitrJammat1Controller,
                    style: GoogleFonts.poppins(fontSize: 10),
                    readOnly: true,
                    onTap: () => _selectTime(
                      context,
                      eidUlFitrJammat1Controller,
                    ),
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
          ),

          Divider(thickness: 1, color: AppColors.blackColor),

          // Jammat 2
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.getString('jamaat2', currentLocale),
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
                    controller: eidUlFitrJammat2Controller,
                    style: GoogleFonts.poppins(fontSize: 10),
                    readOnly: true,
                    onTap: () => _selectTime(
                      context,
                      eidUlFitrJammat2Controller,
                    ),
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
          ),

          const SizedBox(height: 30),

          Consumer<SubAdminTimingsProvider>(
            builder: (context, provider, _) {
              final navigator = Navigator.of(context);
              final isSaved = provider.isEidSaved("eidUlFitr");

              return GestureDetector(
                onTap:
                (provider.isLoading || isSaved)
                    ? null
                    : () async {
                  if (eidUlFitrJammat1Controller.text.isEmpty ||
                      eidUlFitrJammat2Controller.text.isEmpty) {
                    ToastHelper.show(
                      AppStrings.getString('enterBothJammatTimes', currentLocale),
                    );
                    return;
                  }

                  try {
                    await provider.addEidTiming(
                      jammat1: eidUlFitrJammat1Controller.text,
                      jammat2: eidUlFitrJammat2Controller.text,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    );

                    ToastHelper.show(
                      AppStrings.getString('eidTimingsSaved', currentLocale),
                    );

                    eidUlFitrJammat1Controller.clear();
                    eidUlFitrJammat2Controller.clear();

                    navigator.pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const AdminBottomNavigationBar(),
                      ),
                    );
                  } catch (e) {
                    ErrorHandler.showError(e);
                  }
                },
                child: Container(
                  height: 40,
                  width: 200,
                  decoration: BoxDecoration(
                    color: (provider.isLoading || isSaved)
                        ? Colors.grey
                        : AppColors.mainColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: provider.isLoading
                        ? CustomCircularProgressIndicator(
                      size: 60,
                      color: AppColors.backgroundColor1,
                      spinKitType: SpinKitType.chasingDots,
                    )
                        : Text(
                      isSaved
                          ? AppStrings.getString('alreadySaved', currentLocale)
                          : AppStrings.getString('save', currentLocale),
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteBackground,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}