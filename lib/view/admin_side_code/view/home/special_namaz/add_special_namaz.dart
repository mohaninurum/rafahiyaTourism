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

class AddSpecialNamaz extends StatefulWidget {
  const AddSpecialNamaz({super.key});

  @override
  State<AddSpecialNamaz> createState() => _AddSpecialNamazState();
}

class _AddSpecialNamazState extends State<AddSpecialNamaz> {
  // 3 rows (name + time)
  final namaz1NameController = TextEditingController();
  final namaz1TimeController = TextEditingController();
  final namaz2NameController = TextEditingController();
  final namaz2TimeController = TextEditingController();
  final namaz3NameController = TextEditingController();
  final namaz3TimeController = TextEditingController();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
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

  Widget _buildRow(
      String label,
      TextEditingController nameController,
      TextEditingController timeController,
      String currentLocale,
      ) {
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
                width: 120,
                height: 35,
                child: TextFormField(
                  controller: nameController,
                  style: GoogleFonts.poppins(fontSize: 10),
                  decoration: InputDecoration(
                    hintText: AppStrings.getString('namazName', currentLocale),
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
              const SizedBox(width: 10),
              SizedBox(
                width: 100,
                height: 35,
                child: TextFormField(
                  controller: timeController,
                  style: GoogleFonts.poppins(fontSize: 10),
                  readOnly: true,
                  onTap: () => _selectTime(context, timeController),
                  decoration: InputDecoration(
                    hintText: AppStrings.getString('time', currentLocale),
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
        ],
      ),
    );
  }

  String _getNamazLabel(int index, String currentLocale) {
    return '${AppStrings.getString('namaz', currentLocale)} $index';
  }

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubAdminTimingsProvider>().listenToSpecialNamaz(userId);
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
          AppStrings.getString('specialNamaz', currentLocale),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        children: [
          _buildRow(_getNamazLabel(1, currentLocale), namaz1NameController, namaz1TimeController, currentLocale),
          _buildRow(_getNamazLabel(2, currentLocale), namaz2NameController, namaz2TimeController, currentLocale),
          _buildRow(_getNamazLabel(3, currentLocale), namaz3NameController, namaz3TimeController, currentLocale),
          const SizedBox(height: 40),
          Consumer<SubAdminTimingsProvider>(
            builder: (context, provider, _) {
              final navigator = Navigator.of(context);
              final isSaved = provider.isSpecialTimeSave("specialNamaz");

              return GestureDetector(
                onTap:
                (provider.isLoading || isSaved)
                    ? null
                    : () async {
                  // ✅ Modified Validation - At least one namaz should be filled
                  bool hasAtLeastOneNamaz = false;
                  List<List<TextEditingController>> namazPairs = [
                    [namaz1NameController, namaz1TimeController],
                    [namaz2NameController, namaz2TimeController],
                    [namaz3NameController, namaz3TimeController],
                  ];

                  for (var pair in namazPairs) {
                    if (pair[0].text.isNotEmpty && pair[1].text.isNotEmpty) {
                      hasAtLeastOneNamaz = true;
                      break;
                    }
                  }

                  if (!hasAtLeastOneNamaz) {
                    ToastHelper.show(AppStrings.getString('enterAtLeastOneNamaz', currentLocale));
                    return;
                  }

                  try {
                    await provider.specialNamazTiming(
                      namaz1Name: namaz1NameController.text.isEmpty ? "" : namaz1NameController.text,
                      namaz1Time: namaz1TimeController.text.isEmpty ? "" : namaz1TimeController.text,
                      namaz2Name: namaz2NameController.text.isEmpty ? "" : namaz2NameController.text,
                      namaz2Time: namaz2TimeController.text.isEmpty ? "" : namaz2TimeController.text,
                      namaz3Name: namaz3NameController.text.isEmpty ? "" : namaz3NameController.text,
                      namaz3Time: namaz3TimeController.text.isEmpty ? "" : namaz3TimeController.text,
                      userId: FirebaseAuth.instance.currentUser!.uid,
                    );

                    ToastHelper.show(AppStrings.getString('specialNamazSaved', currentLocale));

                    namaz1NameController.clear();
                    namaz1TimeController.clear();
                    namaz2NameController.clear();
                    namaz2TimeController.clear();
                    namaz3NameController.clear();
                    namaz3TimeController.clear();

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
        ],
      ),
    );
  }
}