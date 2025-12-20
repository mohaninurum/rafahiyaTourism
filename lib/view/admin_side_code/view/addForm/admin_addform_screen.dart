import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/error_handler.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/admin_side_code/admin_bottom_navigationbar.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/utils/circular_indicator_spinkit.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/eid_timing/add_eid_timing_screen.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/home/special_namaz/add_special_namaz.dart';

import '../../../../const/color.dart';
import '../../../../const/toast_helper.dart';
import '../../data/subAdminProvider/bayan_provider.dart';
import '../../data/subAdminProvider/sub_admin_timings_provider.dart';
import '../home/prohibited_timing/add_prohibited_time.dart';
import '../home/sunset_timing/add_sunset_timing.dart';
import '../widgets/hadiya_detail_form.dart';
import '../widgets/jumma_namaz_input.dart';
import '../widgets/namaz_time_input.dart';
import '../widgets/share_bayan_dialog.dart';

class AdminAddFormScreen extends StatefulWidget {
  const AdminAddFormScreen({super.key});

  @override
  State<AdminAddFormScreen> createState() => _AdminAddFormScreenState();
}

class _AdminAddFormScreenState extends State<AdminAddFormScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _mosqueOffsetAnimation;
  late Animation<double> _fadeAnimation;

  TextEditingController tuluTimeController = TextEditingController();
  TextEditingController gurubTimeController = TextEditingController();
  TextEditingController zawalTimeController = TextEditingController();
  TextEditingController sehrTimeController = TextEditingController();
  TextEditingController iftarTimeController = TextEditingController();
  TextEditingController eidUlFitrJammat1Controller = TextEditingController();
  TextEditingController eidUlFitrJammat2Controller = TextEditingController();
  TextEditingController prohibitedTiming1Controller = TextEditingController();
  TextEditingController prohibitedTiming2Controller = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _selectTime(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: _scaffoldKey.currentContext!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      controller.text = picked.format(_scaffoldKey.currentContext!);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _mosqueOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/container_image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    AppStrings.getString('addTimings', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.topLeft,
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
                    AppStrings.getString('namazTiming', currentLocale),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  children: [
                    const SizedBox(height: 10),
                    NamazTimeInput(
                      namazName: AppStrings.getString('fajr', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 30),
                    NamazTimeInput(
                      namazName: AppStrings.getString('duhur', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 30),
                    NamazTimeInput(
                      namazName: AppStrings.getString('asr', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 30),
                    NamazTimeInput(
                      namazName: AppStrings.getString('maghrib', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 30),
                    NamazTimeInput(
                      namazName: AppStrings.getString('isha', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
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
                    AppStrings.getString('jummaTiming', currentLocale),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  children: [
                    JumaNamazInput(
                      namazName: AppStrings.getString('jamat1', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                    const SizedBox(height: 20),
                    JumaNamazInput(
                      namazName: AppStrings.getString('jamat2', currentLocale),
                      imamId: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AddSunsetTiming(),
              const SizedBox(height: 20),

              Container(
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
                    AppStrings.getString('ramzanTiming', currentLocale),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  childrenPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.getString('sehr', currentLocale),
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
                              controller: sehrTimeController,
                              style: GoogleFonts.poppins(fontSize: 10),
                              readOnly: true,
                              onTap: () => _selectTime(context, sehrTimeController),
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
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Divider(thickness: 1, color: AppColors.blackColor),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.getString('iftar', currentLocale),
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
                              controller: iftarTimeController,
                              style: GoogleFonts.poppins(fontSize: 10),
                              readOnly: true,
                              onTap: () => _selectTime(context, iftarTimeController),
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
                    const SizedBox(height: 40),

                    Consumer<SubAdminTimingsProvider>(
                      builder: (context, provider, _) {
                        final navigator = Navigator.of(context);
                        final mosqueId = FirebaseAuth.instance.currentUser!.uid;

                        provider.listenToRamzanTiming(mosqueId);

                        return GestureDetector(
                          onTap: provider.ramzanExists || provider.isLoading
                              ? null
                              : () async {
                            if (sehrTimeController.text.isEmpty ||
                                iftarTimeController.text.isEmpty) {
                              ToastHelper.show(AppStrings.getString('enterSehrIftarTimes', currentLocale));
                              return;
                            }

                            try {
                              await provider.addRamzanTiming(
                                sehrTime: sehrTimeController.text,
                                iftarTime: iftarTimeController.text,
                                mosqueId: mosqueId,
                              );
                              ToastHelper.show(AppStrings.getString('ramzanTimingsSaved', currentLocale));
                              sehrTimeController.clear();
                              iftarTimeController.clear();
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
                              color: provider.ramzanExists
                                  ? Colors.grey
                                  : AppColors.mainColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: provider.isLoading
                                  ? CustomCircularProgressIndicator(
                                size: 60,
                                color: AppColors.webPartBackgroundColor,
                                spinKitType: SpinKitType.chasingDots,
                              )
                                  : Text(
                                provider.ramzanExists
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
              ),

              const SizedBox(height: 20),

              AddEidTimingScreen(),
              const SizedBox(height: 20),
              AddProhibitedTime(),
              const SizedBox(height: 20),
              AddSpecialNamaz(),
              const SizedBox(height: 20),
              HadiyaBankDetailsForm(),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ShareBayanDialog(),
                      );
                    },
                    child: Consumer<BayanProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          height: 52,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: provider.isLoading
                                ? const CustomCircularProgressIndicator(
                              size: 24,
                              color: Colors.white,
                              spinKitType: SpinKitType.circle,
                            )
                                : Text(
                              AppStrings.getString('shareAnnouncement', currentLocale),
                              style: GoogleFonts.poppins(
                                color: AppColors.whiteBackground,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}