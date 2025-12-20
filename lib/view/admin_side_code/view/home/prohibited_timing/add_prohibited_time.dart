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

class AddProhibitedTime extends StatefulWidget {
  const AddProhibitedTime({super.key});

  @override
  State<AddProhibitedTime> createState() => _AddProhibitedTimeState();
}

class _AddProhibitedTimeState extends State<AddProhibitedTime> {
  // 8 controllers (From + To for 4 rows)
  final time1FromController = TextEditingController();
  final time1ToController = TextEditingController();
  final time2FromController = TextEditingController();
  final time2ToController = TextEditingController();
  final time3FromController = TextEditingController();
  final time3ToController = TextEditingController();
  final time4FromController = TextEditingController();
  final time4ToController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      controller.text = picked.format(context);
    }
  }

  Widget _buildRow(String label, TextEditingController fromController,
      TextEditingController toController, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6),
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
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 35,
                child: TextFormField(
                  controller: fromController,
                  style: GoogleFonts.poppins(fontSize: 10),
                  readOnly: true,
                  onTap: () => _selectTime(context, fromController),
                  decoration: InputDecoration(
                    hintText: AppStrings.getString('from', currentLocale),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                height: 35,
                child: TextFormField(
                  controller: toController,
                  style: GoogleFonts.poppins(fontSize: 10),
                  readOnly: true,
                  onTap: () => _selectTime(context, toController),
                  decoration: InputDecoration(
                    hintText: AppStrings.getString('to', currentLocale),
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
        ],
      ),
    );
  }

  String _getTimeLabel(int index, String currentLocale) {
    return '${AppStrings.getString('time', currentLocale)} $index';
  }

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubAdminTimingsProvider>().listenToProhibitedTime(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

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
          AppStrings.getString('prohibitedTiming', currentLocale),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding:
        const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        children: [
          _buildRow(_getTimeLabel(1, currentLocale), time1FromController, time1ToController, currentLocale),
          _buildRow(_getTimeLabel(2, currentLocale), time2FromController, time2ToController, currentLocale),
          _buildRow(_getTimeLabel(3, currentLocale), time3FromController, time3ToController, currentLocale),
          _buildRow(_getTimeLabel(4, currentLocale), time4FromController, time4ToController, currentLocale),
          const SizedBox(height: 40),
          Consumer<SubAdminTimingsProvider>(
            builder: (context, provider, _) {
              final navigator = Navigator.of(context);
              final isSaved = provider.isProhibitedTimeSave("prohibitedTime");

              return GestureDetector(
                onTap: (provider.isLoading || isSaved)
                    ? null
                    : () async {
                  bool hasAtLeastOneTime = false;
                  List<List<TextEditingController>> timePairs = [
                    [time1FromController, time1ToController],
                    [time2FromController, time2ToController],
                    [time3FromController, time3ToController],
                    [time4FromController, time4ToController],
                  ];

                  for (var pair in timePairs) {
                    if (pair[0].text.isNotEmpty && pair[1].text.isNotEmpty) {
                      hasAtLeastOneTime = true;
                      break;
                    }
                  }

                  if (!hasAtLeastOneTime) {
                    ToastHelper.show(AppStrings.getString('enterAtLeastOneTimePair', currentLocale));
                    return;
                  }

                  try {
                    await provider.prohibitedTiming(
                      time1From: time1FromController.text.isEmpty ? "" : time1FromController.text,
                      time1To: time1ToController.text.isEmpty ? "" : time1ToController.text,
                      time2From: time2FromController.text.isEmpty ? "" : time2FromController.text,
                      time2To: time2ToController.text.isEmpty ? "" : time2ToController.text,
                      time3From: time3FromController.text.isEmpty ? "" : time3FromController.text,
                      time3To: time3ToController.text.isEmpty ? "" : time3ToController.text,
                      time4From: time4FromController.text.isEmpty ? "" : time4FromController.text,
                      time4To: time4ToController.text.isEmpty ? "" : time4ToController.text,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    );

                    ToastHelper.show(AppStrings.getString('prohibitedTimingsSaved', currentLocale));

                    time1FromController.clear();
                    time1ToController.clear();
                    time2FromController.clear();
                    time2ToController.clear();
                    time3FromController.clear();
                    time3ToController.clear();
                    time4FromController.clear();
                    time4ToController.clear();

                    navigator.pushReplacement(MaterialPageRoute(
                        builder: (_) => const AdminBottomNavigationBar()));
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
        ],
      ),
    );
  }
}