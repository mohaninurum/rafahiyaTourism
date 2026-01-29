import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/app_state_proivder.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/utils/services/splash_services.dart';
import 'package:rafahiyatourism/view/customer_drawer.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/home_slider_images_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/locale_provider.dart';
import '../../utils/route_observer/route_observer.dart';
import 'home_screen_helper/home_app_bar_actions.dart';
import 'home_screen_helper/home_carousal_slider.dart';
import 'home_screen_helper/home_masjid_view.dart';
import 'home_screen_helper/home_nearby_masjid.dart';

class HomeScreen extends StatefulWidget {
  final AuthUserModel? user;

  const HomeScreen({super.key, this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // static final routeObserver = RouteObserver<ModalRoute<void>>();
  SplashServices services = SplashServices();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() =>
        Provider.of<SliderImagesProvider>(context, listen: false).loadSliderImages());

    // Listen to changes in AppStateProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      appState.addListener(_checkForRestartDialog);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to RouteObserver when dependencies change
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);  // ← This line connects everything
  }
  }

  void _checkForRestartDialog() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (appState.showRestartDialog && ModalRoute.of(context)?.isCurrent == true) {
      print("★★★ RESTART DIALOG TRIGGERED via listener! ★★★");
      _showRestartDialog();
      appState.setShowRestartDialog(false); // reset flag
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.removeListener(_checkForRestartDialog);
    _tabController.dispose();
    super.dispose();
  }

  // Called when another route pops and this route becomes visible again
  @override
  void didPopNext() {
    super.didPopNext();
    print("didPopNext → checking for restart dialog...");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      print("Restart flag status: ${appState.showRestartDialog}");
      if (appState.showRestartDialog) {
        print("★★★ Showing restart dialog after returning to HomeScreen! ★★★");
        _showRestartDialog();
        appState.setShowRestartDialog(false);
      } else {
        print("No restart dialog needed");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: screenHeight * 0.43,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/container_image.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                left: screenWidth * 0.05,
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: screenWidth * 0.08,
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              Positioned(
                top: screenHeight * 0.04,
                right: screenWidth * 0.05,
                child: AppBarActions(screenWidth: screenWidth),
              ),
              HomeCarouselSlider(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                isSmallScreen: isSmallScreen,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: screenHeight * 0.07,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFD7E72).withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: screenHeight * 0.04,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.white,
                            dividerColor: Colors.transparent,
                            unselectedLabelColor: Colors.black,
                            indicator: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelStyle: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 9 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            overlayColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            tabs:  [
                              Tab(child: Text("${AppStrings.getString('myMasjid', currentLocale)} 1",style: GoogleFonts.poppins(),)),
                              Tab(child: Text("${AppStrings.getString('myMasjid', currentLocale)} 2",style: GoogleFonts.poppins(),)),
                              Tab(child: Text(AppStrings.getString('nearbyMasjid', currentLocale),style: GoogleFonts.poppins(),)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MasjidView(tabIndex: 0),
                MasjidView(tabIndex: 1),
                NearByMasjid(tabIndex: 2,
                )],
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: (){
          _launchWhatsApp(currentLocale);
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/whatsapp.png'),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }



  Future<void> _launchWhatsApp(final currentLocale) async {


    final phoneNumber = '+919552378468';
    final url = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw '${AppStrings.getString('couldNotLaunch', currentLocale)} $url';
      }
    } catch (e) {
      print('${AppStrings.getString('errorLaunchingWhatsApp', currentLocale)}: $e');
    }
  }

  void _showRestartDialog() {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.92),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 40,
                    bottom: 32,
                    left: 28,
                    right: 28,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated Icon with rotating border
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer rotating ring
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.mainColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                          ),
                          // Inner gradient circle
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.mainColor.withOpacity(0.15),
                                  AppColors.mainColor.withOpacity(0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainColor.withOpacity(0.25),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.restart_alt_rounded,
                                size: 50,
                                color: AppColors.mainColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Title with gradient text effect
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            AppColors.mainColor,
                            AppColors.mainColor.withOpacity(0.8),
                          ],
                        ).createShader(bounds),
                        child: Text(
                          AppStrings.getString('Restart Required', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Description with better styling
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          AppStrings.getString(
                            'Please Restart App For Getting Scheduled Notifications On Time',
                            currentLocale,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF555555),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Premium styled button
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.mainColor.withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.mainColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              Restart.restartApp();
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.mainColor,
                                    AppColors.mainColor.withOpacity(0.85),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restart_alt_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.getString('Restart', currentLocale),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showRestartDialog() {
  //   final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  //   final currentLocale = localeProvider.locale?.languageCode ?? 'en';
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierColor: Colors.black.withOpacity(0.5),
  //     builder: (BuildContext dialogContext) {
  //       return Dialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //         elevation: 8,
  //         backgroundColor: Colors.white,
  //         child: Container(
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(24),
  //             gradient: LinearGradient(
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //               colors: [
  //                 Colors.white,
  //                 Colors.white.withOpacity(0.98),
  //               ],
  //             ),
  //           ),
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 // Icon Container with gradient background
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     gradient: LinearGradient(
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                       colors: [
  //                         AppColors.mainColor.withOpacity(0.2),
  //                         AppColors.mainColor.withOpacity(0.05),
  //                       ],
  //                     ),
  //                   ),
  //                   child: Center(
  //                     child: Icon(
  //                       Icons.restart_alt_rounded,
  //                       size: 45,
  //                       color: AppColors.mainColor,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 24),
  //
  //                 // Title
  //                 Text(
  //                   AppStrings.getString('Restart Required', currentLocale),
  //                   style: GoogleFonts.poppins(
  //                     fontWeight: FontWeight.w700,
  //                     fontSize: 20,
  //                     color: const Color(0xFF1a1a1a),
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 12),
  //
  //                 // Description
  //                 Text(
  //                   AppStrings.getString(
  //                     'Please Restart App For Getting Scheduled Notifications On Time',
  //                     currentLocale,
  //                   ),
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w400,
  //                     color: const Color(0xFF666666),
  //                     height: 1.5,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //                 const SizedBox(height: 32),
  //
  //                 // Restart Button
  //                 Container(
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(12),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: AppColors.mainColor.withOpacity(0.3),
  //                         blurRadius: 12,
  //                         offset: const Offset(0, 4),
  //                       ),
  //                     ],
  //                   ),
  //                   child: ElevatedButton(
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: AppColors.mainColor,
  //                       foregroundColor: Colors.white,
  //                       padding: const EdgeInsets.symmetric(vertical: 14),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       elevation: 0,
  //                     ),
  //                     onPressed: () {
  //                       Navigator.of(dialogContext).pop();
  //                       Restart.restartApp();
  //                     },
  //                     child: Text(
  //                       AppStrings.getString('restart', currentLocale),
  //                       style: GoogleFonts.poppins(
  //                         color: Colors.white,
  //                         fontWeight: FontWeight.w600,
  //                         fontSize: 16,
  //                         letterSpacing: 0.5,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _showRestartDialog() {
  //   final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  //   final currentLocale = localeProvider.locale?.languageCode ?? 'en';
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         title: Column(
  //           children: [
  //             Icon(
  //               Icons.restart_alt, // or Icons.notifications_active
  //               size: 50,
  //               color: AppColors.mainColor,
  //             ),
  //             const SizedBox(height: 10),
  //             Text(
  //               AppStrings.getString('Restart Required', currentLocale),
  //               style: GoogleFonts.poppins(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 18,
  //               ),
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //         content: Text(
  //           AppStrings.getString('Please Restart App For Getting Scheduled Notifications On Time', currentLocale),
  //           style: GoogleFonts.poppins(fontSize: 14),
  //           textAlign: TextAlign.center,
  //         ),
  //         actions: [
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.mainColor,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(dialogContext).pop();
  //                     Restart.restartApp();
  //                   },
  //                   child: Text(
  //                     AppStrings.getString('restart', currentLocale),
  //                     style: GoogleFonts.poppins(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

// // Add this method
  // void _showRestartDialog() {
  //   final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  //   final currentLocale = localeProvider.locale?.languageCode ?? 'en';
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text(AppStrings.getString('restartRequired', currentLocale)),
  //         content: Text(AppStrings.getString('pleaseRestartAppForNotifications', currentLocale)),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text(AppStrings.getString('restart', currentLocale)),
  //             onPressed: () {
  //               Restart.restartApp();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

}