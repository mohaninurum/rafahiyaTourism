
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/add_sub_super_admin_provider.dart';
import 'package:rafahiyatourism/provider/add_umrah_packages_provider.dart';
import 'package:rafahiyatourism/provider/ads_provider.dart';
import 'package:rafahiyatourism/provider/home_masjid_data_provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/provider/mosque_search_provider.dart';
import 'package:rafahiyatourism/provider/multi_mosque_provider.dart';
import 'package:rafahiyatourism/provider/nearby_mosque_provider.dart';
import 'package:rafahiyatourism/provider/notification_list_provider.dart';
import 'package:rafahiyatourism/provider/notify_provider.dart';
import 'package:rafahiyatourism/provider/one_signal_providers.dart';
import 'package:rafahiyatourism/provider/request_update_time_subadmin_provider.dart';
import 'package:rafahiyatourism/provider/user_announcement_provider.dart';
import 'package:rafahiyatourism/provider/user_country_provider.dart';
import 'package:rafahiyatourism/services/new_notification_service.dart';
import 'package:rafahiyatourism/services/notification_scheduled.dart';
import 'package:rafahiyatourism/services/notification_services.dart' as noti;
import 'package:rafahiyatourism/utils/model/user_notifications.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/add_hadiya_maulana_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_login_provider.dart';
import 'package:rafahiyatourism/provider/masjid_setting_provider.dart';
import 'package:rafahiyatourism/provider/notification_provider.dart';
import 'package:rafahiyatourism/provider/signup_provider.dart';
import 'package:rafahiyatourism/provider/splash_provider.dart';
import 'package:rafahiyatourism/provider/tasbih_provider.dart';
import 'package:rafahiyatourism/provider/user_login_provider.dart';
import 'package:rafahiyatourism/provider/user_profile_provider.dart';
import 'package:rafahiyatourism/provider/wallet_doc_provider.dart';
import 'package:rafahiyatourism/provider/zakat_provider.dart';
import 'package:rafahiyatourism/utils/model/user_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_otpVerification.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_register_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/bayan_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/location_search_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/map_search_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/prayer_times_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/sub-admin_sunset_timing_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/sub_admin_forgot_password_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/sub_admin_login_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/sub_admin_profile_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/sub_admin_timings_provider.dart';
import 'package:rafahiyatourism/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/faq/faq_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/general_annoucement/super_admin_general_annoucement.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/hijri_date_provider/hijri_date_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/home_images_slider_provider/home_slider_images_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/live_stream_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/marquee/marquee_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/pending_admin_imam_list.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/pending_hadiyah_provider/pending_hadiyah_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/sub_admin_detail_provider/sub_admin_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/super_admin_community_service/super_admin_community_service_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/super_admin_salah_provider/super_admin_salah_provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/tutorial_videos_provider/tutorial_videos_provider.dart';
import 'package:rafahiyatourism/view/user_notification_screen.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  OneSignal.initialize("2a8636c3-a652-44ec-a07f-b489cd595551");

  await OneSignal.Notifications.requestPermission(true);
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);



  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  noti.NotificationService().initializeNotificationChannels();
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
  // Add a small delay to ensure subscription is established after permission
  await Future.delayed(Duration(seconds: 15));

  OneSignal.User.pushSubscription.addObserver((state) {
    final playerId = state.current.id;
    print("🔥 OneSignal PlayerID updated: $playerId");
  });

  runApp(const MyApp());


}





class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static BuildContext? navigatorContext; // globally accessible context

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static BuildContext? navigatorContext;

  @override
  Widget build(BuildContext context) {
    // Save context globally for navigation
    MyApp.navigatorContext = context;
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child){
        return MultiProvider(
          providers: [
            // Core providers
            ChangeNotifierProvider(create: (_) => SplashScreenProvider()),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),

            // Authentication providers
            ChangeNotifierProvider(create: (_) => SignupProvider()),
            ChangeNotifierProvider(create: (_) => AdminsLoginProvider()),
            ChangeNotifierProvider(create: (_) => AdminRegisterProvider()),
            ChangeNotifierProvider(create: (_) => AdminOtpVerification()),
            ChangeNotifierProvider(create: (_) => UserLoginProvider()),
            ChangeNotifierProvider(create: (_) => UserProfileProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminLoginProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminForgotPasswordProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),

            // Mosque and location providers
            ChangeNotifierProvider(create: (context) => MultiMosqueProvider()),
            ChangeNotifierProvider(create: (context) => HomeMasjidDataProvider()),
            ChangeNotifierProvider(create: (_) => MasjidSettingsProvider()),
            ChangeNotifierProvider(create: (_) => NearbyMosqueProvider()),
            ChangeNotifierProvider(create: (_) => MosqueSearchProvider()),
            ChangeNotifierProvider(create: (_) => MapSearchProvider()),
            ChangeNotifierProvider(create: (_) => LocationSearchProvider()),

            // Hijri Date Provider (Important for your feature)
            ChangeNotifierProvider(create: (_) => HijriDateProvider()),

            // User country provider (needed for Hijri date)
            ChangeNotifierProvider(create: (_) => UserCountryProvider()),

            // Super Admin providers
            ChangeNotifierProvider(create: (_) => AddSubSuperAdminProvider()),
            ChangeNotifierProvider(create: (_) => PendingAdminImamListProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminDetailProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminProfileProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminTimingsProvider()),

            // Content management providers
            ChangeNotifierProvider(create: (_) => SliderImagesProvider()),
            ChangeNotifierProvider(create: (_) => TutorialVideoProvider()),
            ChangeNotifierProvider(create: (_) => BayanProvider()),
            ChangeNotifierProvider(create: (_) => GeneralAnnouncementProvider()),
            ChangeNotifierProvider(create: (_) => MarqueeProvider()),
            ChangeNotifierProvider(create: (_) => LiveStreamProvider(context)),
            ChangeNotifierProvider(create: (_) => AdsProvider()),

            // Prayer and timing providers
            ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
            ChangeNotifierProvider(create: (_) => SSunsetTimingProvider()),
            ChangeNotifierProvider(create: (_) => SuperAdminSalahProvider()),

            // Utility providers
            ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
            ChangeNotifierProvider(create: (_) => TasbihProvider()),
            ChangeNotifierProvider(create: (_) => ZakatProvider()),
            ChangeNotifierProvider(create: (_) => WalletDocumentProvider()),
            ChangeNotifierProvider(create: (_) => AddUmrahPackageProvider()),

            // Community and service providers
            ChangeNotifierProvider(create: (_) => CommunityServiceProvider()),
            ChangeNotifierProvider(create: (_) => HadiyaProvider()),
            ChangeNotifierProvider(create: (_) => PendingHadiyaProvider()),

            // App settings providers
            ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
            ChangeNotifierProvider(create: (_) => FAQProvider()),

            // Announcement providers
            ChangeNotifierProvider(create: (_) => UserAnnouncementProvider()),
            ChangeNotifierProvider(create: (_) => OneSignalNotificationProviders()),
            ChangeNotifierProvider(create: (_) => RequestUpdateTimeSubAdminProvider()),
            ChangeNotifierProvider(create: (_) => NotificationListProvider()),

          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Rafahiya Tourism',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const AppInitializer(),
          ),
        );
      },
    );
  }
}



class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return FutureBuilder(
      future: _initializeProviders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return const SplashScreen();
      },
    );
  }

  Future<void> _initializeProviders(BuildContext context) async {
    final hijriDateProvider = Provider.of<HijriDateProvider>(context, listen: false);
    await hijriDateProvider.loadAllCountryDateSettings();
    await hijriDateProvider.loadCountriesFromSubAdmins();
  }
}