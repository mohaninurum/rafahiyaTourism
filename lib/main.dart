import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/add_sub_super_admin_provider.dart';
import 'package:rafahiyatourism/provider/add_umrah_packages_provider.dart';
import 'package:rafahiyatourism/provider/ads_provider.dart';
import 'package:rafahiyatourism/provider/app_state_proivder.dart';
import 'package:rafahiyatourism/provider/home_masjid_data_provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/provider/mosque_search_provider.dart';
import 'package:rafahiyatourism/provider/multi_mosque_provider.dart';
import 'package:rafahiyatourism/provider/nearby_mosque_provider.dart';
import 'package:rafahiyatourism/provider/notification_list_provider.dart';
import 'package:rafahiyatourism/provider/notify_provider.dart';
import 'package:rafahiyatourism/provider/request_update_time_subadmin_provider.dart';
import 'package:rafahiyatourism/provider/setting_provider.dart';
import 'package:rafahiyatourism/provider/user_announcement_provider.dart';
import 'package:rafahiyatourism/provider/user_country_provider.dart';
import 'package:rafahiyatourism/utils/route_observer/route_observer.dart';
import 'package:rafahiyatourism/utils/services/get_time_zone.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'firebase_options.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void openNotificationListScreen() {
  final nav = rootNavigatorKey.currentState;
  if (nav == null) return;

  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || uid.isEmpty) return;

  nav.push(
    MaterialPageRoute(
      builder: (context) => UserNotificationScreen(currentUserId: uid),
    ),
  );
}


Future<void> createNotificationChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  try {
    const AndroidNotificationChannel fajrChannel = AndroidNotificationChannel(
      'rafahiya_channel_fajr_V8', // Bumped to V8
      'Fajr Azaan Notifications_V8',
      description: 'Channel for Fajr prayer notifications_V8',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('alert_sound1'),
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    const AndroidNotificationChannel otherNamazChannel =
        AndroidNotificationChannel(
          'rafahiya_channel_other_V8', // Bumped to V8
          'Other Namaz Notifications_V8',
          description: 'Channel for Duhur, Asr, Magrib, Isha notifications_V8',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound('alert_sound'),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          'rafahiya_channel_general_V8', // Bumped to V8
          'General Notifications_V8',
          description: 'Channel for general notifications_V8',
          importance: Importance.max,
          playSound: false,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.notification,
        );

    final androidPlugin =
        plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(fajrChannel);
      await androidPlugin.createNotificationChannel(otherNamazChannel);
      await androidPlugin.createNotificationChannel(generalChannel);
    }
  } catch (e) {
    debugPrint('❌ Error creating channels: $e');
  }
}

class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() => _instance;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  Future<void> initializeNotificationChannels() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: DarwinInitializationSettings(),
        );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await createNotificationChannels(_flutterLocalNotificationsPlugin);
  }

  static Future<void> initialize({
    required String currentUserId,
    required String collectionName,
  }) async {
    debugPrint(
      "✅ NotificationService.initialize CALLED with userId=$currentUserId",
    );

    await _instance._requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _instance._flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        openNotificationListScreen();
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FG RAW : ${message.toMap()}");
      debugPrint("🔥 FOREGROUND NOTIFICATION ARRIVED");
      debugPrint(
        "Title: ${message.notification?.title ?? message.data['title']}",
      );
      debugPrint("Body: ${message.notification?.body ?? message.data['body']}");
      debugPrint(
        "Channel: ${message.notification?.android?.channelId ?? message.data['android_channel_id']}",
      );
      debugPrint("Data: ${message.data}");
      _instance._showLocalNotificationFromRemote(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      openNotificationListScreen();
    });

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        openNotificationListScreen();
      });
    }

    final token = await _instance._messaging.getToken();
    if (token != null && currentUserId.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(currentUserId)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }

    // 🔥 Subscribe to topic AFTER token is available
    try {
      await subscribeToTimezoneTopicSmart();
      debugPrint("✅ SUBSCRIBED TO TOPIC: Asia_Kolkata");
    } catch (e) {
      debugPrint("❌ TOPIC SUBSCRIPTION FAILED: $e");
    }

    _instance._messaging.onTokenRefresh.listen((newToken) async {
      if (currentUserId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(currentUserId)
            .set({'fcmToken': newToken}, SetOptions(merge: true)
        );

        await subscribeToTimezoneTopicSmart();
      }
    });
  }

  static String _normalizeTopic(String topic) {
    // Map old timezone names to new ones
    const Map<String, String> timezoneAliases = {
      'Asia_Calcutta': 'Asia_Kolkata',
      'Asia_Saigon': 'Asia_Ho_Chi_Minh',
      'Asia_Katmandu': 'Asia_Kathmandu',
      'America_Indianapolis': 'America_Indiana_Indianapolis',
      // Add more as needed
    };
    return timezoneAliases[topic] ?? topic;
  }

  static Future<void> subscribeToTimezoneTopicSmart() async {
    try {
      // final prefs = await SharedPreferences.getInstance();
      // final String timeZone = await GetTimeZone.setupTimezone();
      //
      // // ✅ Normalize BEFORE subscribing
      // final String rawTopic = timeZone.replaceAll('/', '_');
      // final String newTopic = _normalizeTopic(rawTopic);
      //
      // final String? oldTopic = prefs.getString("timezone_topic");
      //
      // if (oldTopic != null && oldTopic != newTopic) {
      //   await FirebaseMessaging.instance.unsubscribeFromTopic(oldTopic);
      //   print("🗑️ UNSUBSCRIBED FROM OLD TOPIC: $oldTopic");
      // }
      //
      // await FirebaseMessaging.instance.subscribeToTopic(newTopic);
      // await prefs.setString("timezone_topic", newTopic);
      // print("✅ SUBSCRIBED TO TOPIC: $newTopic");

    } catch (e) {
      print("❌ SMART SUBSCRIPTION FAILED: $e");
    }
  }

  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('🔔 FCM Permission Status: ${settings.authorizationStatus}');

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          final status = await Permission.notification.status;
          if (status.isDenied) {
            final result = await Permission.notification.request();
            debugPrint(
              result.isGranted
                  ? '✅ Android 13+ permission granted.'
                  : '🚫 Android 13+ permission denied.',
            );
          } else if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error requesting permission: $e');
    }
  }

  Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    String title =
        message.notification?.title ??
        message.data['title'] ??
        message.data['headings']?['en'] ?? 'RafahiyaTourism';
    String body =
        message.notification?.body ??
        message.data['body'] ??
        message.data['contents']?['en'] ??
        message.data['message'] ?? 'New notification';
    final android = message.notification?.android;

    String channelId = 'rafahiya_channel_general_V8';
    String channelName = 'General Notifications_V8';
    String channelDesc = 'Channel for general notifications_V8';
    bool playSound = false;
    bool enableVibration = true;
    RawResourceAndroidNotificationSound? customSound;
    bool fullScreenIntent = false;

    String? effectiveChannelId =
        android?.channelId ?? message.data['android_channel_id'] as String?;

    if (effectiveChannelId?.contains('fajr') ?? false) {
      channelId = 'rafahiya_channel_fajr_V8';
      channelName = 'Fajr Azaan Notifications_V8';
      channelDesc = 'Channel for Fajr prayer notifications_V8';
      playSound = true;
      customSound = const RawResourceAndroidNotificationSound('alert_sound1');
      fullScreenIntent = true;
    } else if (effectiveChannelId?.contains('other') ?? false) {
      channelId = 'rafahiya_channel_other_V8';
      channelName = 'Other Namaz Notifications_V8';
      channelDesc = 'Channel for Duhur, Asr, Magrib, Isha notifications_V8';
      playSound = true;
      customSound = const RawResourceAndroidNotificationSound('alert_sound');
      fullScreenIntent = true;
    } else {
      playSound = true;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          playSound: playSound,
          enableVibration: enableVibration,
          sound: customSound,
          channelShowBadge: true,
          visibility: NotificationVisibility.public,
          showWhen: true,
          fullScreenIntent: fullScreenIntent,
          onlyAlertOnce: false,
          category: AndroidNotificationCategory.alarm,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    final platform = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Cancel all previous notifications first (optional but safe)
    await _flutterLocalNotificationsPlugin.cancelAll();

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platform,
      payload: jsonEncode(message.data.toString()),
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  String title =
      message.notification?.title ??
      message.data['title'] ??
      message.data['headings']?['en'] ?? 'RafahiyaTourism';
  String body =
      message.notification?.body ??
      message.data['body'] ??
      message.data['contents']?['en'] ??
      message.data['message'] ?? 'New notification';

  final android = message.notification?.android;

  debugPrint("🔥 BACKGROUND / TERMINATED NOTIFICATION");
  debugPrint("Title: $title");
  debugPrint("Body: $body");
  debugPrint("Data: ${message.data}");
  debugPrint(
    "Channel ID: ${android?.channelId ?? message.data['android_channel_id']}",
  );

  print("BG RAW : ${message.toMap()}");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final fln = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await fln.initialize(initSettings);

  await createNotificationChannels(fln);

  String channelId = 'rafahiya_channel_general_V8';
  String channelName = 'General Notifications_V8';
  String channelDesc = 'Channel for general notifications_V8';
  bool playSound = false;
  bool enableVibration = true;
  RawResourceAndroidNotificationSound? customSound;
  bool fullScreenIntent = false;

  String? effectiveChannelId =
      android?.channelId ?? message.data['android_channel_id'] as String?;

  if (effectiveChannelId?.contains('fajr') ?? false) {
    channelId = 'rafahiya_channel_fajr_V8';
    channelName = 'Fajr Azaan Notifications_V8';
    channelDesc = 'Channel for Fajr prayer notifications_V8';
    playSound = true;
    customSound = const RawResourceAndroidNotificationSound('alert_sound1');
    fullScreenIntent = true;
  } else if (effectiveChannelId?.contains('other') ?? false) {
    channelId = 'rafahiya_channel_other_V8';
    channelName = 'Other Namaz Notifications_V8';
    channelDesc = 'Channel for Duhur, Asr, Magrib, Isha notifications_V8';
    playSound = true;
    customSound = const RawResourceAndroidNotificationSound('alert_sound');
    fullScreenIntent = true;
  } else {
    playSound = false;
  }

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDesc,
    importance: Importance.max,
    priority: Priority.high,
    playSound: playSound,
    enableVibration: enableVibration,
    sound: customSound,
    channelShowBadge: true,
    visibility: NotificationVisibility.public,
    showWhen: true,
    fullScreenIntent: fullScreenIntent,
    category: AndroidNotificationCategory.alarm,
    onlyAlertOnce: false,
  );

  final platform = NotificationDetails(android: androidDetails);

  // Cancel all previous notifications
  await fln.cancelAll();

  await fln.show(0, title, body, platform, payload: jsonEncode(message.data.toString()));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GetTimeZone.setupTimezone();
  timezone.initializeTimeZones();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // === Re-add minimal OneSignal ===
  OneSignal.initialize("2a8636c3-a652-44ec-a07f-b489cd595551"); // your app ID
  OneSignal.Notifications.requestPermission(true); // ask permission
  // Do NOT add any observers or extra config — keep it minimal

  // OneSignal.Notifications.addClickListener((event) {
  //   openNotificationListScreen();
  // });

  //FCM TOKEN
  try {
    final token = await FirebaseMessaging.instance.getToken();
    print("🔥 FCM TOKEN: $token");
  } catch (e) {
    debugPrint("⚠️ FCM token fetch failed (non-fatal): $e");
    // App continues normally — token will be fetched later
  }


  await NotificationService().initializeNotificationChannels();

  final currentUser = FirebaseAuth.instance.currentUser;

  try {
    await NotificationService.initialize(
      currentUserId: currentUser?.uid ?? '',
      collectionName: 'users',
    );
  } catch (e) {
    debugPrint("⚠️ NotificationService init failed (non-fatal): $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static BuildContext? navigatorContext;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    MyApp.navigatorContext = context;
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SplashScreenProvider()),
            ChangeNotifierProvider(create: (_) => LocaleProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
            ChangeNotifierProvider(create: (_) => SignupProvider()),
            ChangeNotifierProvider(create: (_) => AdminsLoginProvider()),
            ChangeNotifierProvider(create: (_) => AdminRegisterProvider()),
            ChangeNotifierProvider(create: (_) => AdminOtpVerification()),
            ChangeNotifierProvider(create: (_) => UserLoginProvider()),
            ChangeNotifierProvider(create: (_) => UserProfileProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminLoginProvider()),
            ChangeNotifierProvider(
              create: (_) => SubAdminForgotPasswordProvider(),
            ),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (context) => MultiMosqueProvider()),
            ChangeNotifierProvider(
              create: (context) => HomeMasjidDataProvider(),
            ),
            ChangeNotifierProvider(create: (_) => MasjidSettingsProvider()),
            ChangeNotifierProvider(create: (_) => NearbyMosqueProvider()),
            ChangeNotifierProvider(create: (_) => MosqueSearchProvider()),
            ChangeNotifierProvider(create: (_) => MapSearchProvider()),
            ChangeNotifierProvider(create: (_) => LocationSearchProvider()),
            ChangeNotifierProvider(create: (_) => HijriDateProvider()),
            ChangeNotifierProvider(create: (_) => UserCountryProvider()),
            ChangeNotifierProvider(create: (_) => AddSubSuperAdminProvider()),
            ChangeNotifierProvider(
              create: (_) => PendingAdminImamListProvider(),
            ),
            ChangeNotifierProvider(create: (_) => SubAdminDetailProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminProfileProvider()),
            ChangeNotifierProvider(create: (_) => SubAdminTimingsProvider()),
            ChangeNotifierProvider(create: (_) => SliderImagesProvider()),
            ChangeNotifierProvider(create: (_) => TutorialVideoProvider()),
            ChangeNotifierProvider(create: (_) => BayanProvider()),
            ChangeNotifierProvider(
              create: (_) => GeneralAnnouncementProvider(),
            ),
            ChangeNotifierProvider(create: (_) => MarqueeProvider()),
            ChangeNotifierProvider(create: (_) => LiveStreamProvider(context)),
            ChangeNotifierProvider(create: (_) => AdsProvider()),
            ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
            ChangeNotifierProvider(create: (_) => SSunsetTimingProvider()),
            ChangeNotifierProvider(create: (_) => SuperAdminSalahProvider()),
            ChangeNotifierProvider(
              create: (_) => NotificationSettingsProvider(),
            ),
            ChangeNotifierProvider(create: (_) => TasbihProvider()),
            ChangeNotifierProvider(create: (_) => ZakatProvider()),
            ChangeNotifierProvider(create: (_) => WalletDocumentProvider()),
            ChangeNotifierProvider(create: (_) => AddUmrahPackageProvider()),
            ChangeNotifierProvider(create: (_) => CommunityServiceProvider()),
            ChangeNotifierProvider(create: (_) => HadiyaProvider()),
            ChangeNotifierProvider(create: (_) => PendingHadiyaProvider()),
            ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
            ChangeNotifierProvider(create: (_) => FAQProvider()),
            ChangeNotifierProvider(create: (_) => UserAnnouncementProvider()),
            ChangeNotifierProvider(
              create: (_) => RequestUpdateTimeSubAdminProvider(),
            ),
            ChangeNotifierProvider(create: (_) => NotificationListProvider()),
            ChangeNotifierProvider(create: (_) => AppStateProvider()),
            ChangeNotifierProvider(create: (_) => SettingProvider()),

          ],
          child: MaterialApp(
            navigatorKey: rootNavigatorKey,
            navigatorObservers: [routeObserver],
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
    setState(() => _isInitialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder(
      future: _initializeProviders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const SplashScreen();
      },
    );
  }

  Future<void> _initializeProviders(BuildContext context) async {
    final hijriDateProvider = Provider.of<HijriDateProvider>(
      context,
      listen: false,
    );
    await hijriDateProvider.loadAllCountryDateSettings();
    await hijriDateProvider.loadCountriesFromSubAdmins();
  }
}
