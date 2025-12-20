//
//
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class NotificationService {
//   NotificationService._();
//   static final NotificationService _instance = NotificationService._();
//   factory NotificationService() => _instance;
//
//   final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   final _messaging = FirebaseMessaging.instance;
//
//
//   Future<void> initializeNotificationChannels() async {
//
//     // Android initialization
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: DarwinInitializationSettings(),
//     );
//
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//
//     // Create notification channels
//     await createNotificationChannels(_flutterLocalNotificationsPlugin);
//   }
//
//   Future<void> createNotificationChannels(
//       FlutterLocalNotificationsPlugin plugin) async {
//
//     try {
//       // Channel 1: Fajr Azaan Channel
//       const AndroidNotificationChannel fajrChannel = AndroidNotificationChannel(
//         'rafahiya_channel_fajr_V2',
//         'Fajr Azaan Notifications_V2',
//         description: 'Channel for Fajr prayer notifications_V2',
//         importance: Importance.max,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('alert_sound1'),
//       );
//
//       // Channel 2: Other Namaz Channel
//       const AndroidNotificationChannel otherNamazChannel = AndroidNotificationChannel(
//         'rafahiya_channel_other_V2',
//         'Other Namaz Notifications_V2',
//         description: 'Channel for Duhur, Asr, Magrib, Isha notifications_V2',
//         importance: Importance.max,
//         playSound: true,
//         sound: RawResourceAndroidNotificationSound('alert_sound'),
//       );
//
//       // Channel 3: General Notifications (No Sound)
//       const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
//         'rafahiya_channel_general_V2',
//         'General Notifications_V2',
//         description: 'Channel for general notifications without sound_V2',
//         importance: Importance.max,
//         playSound: false,
//       );
//
//       // Get Android platform implementation
//       final androidPlugin = plugin.resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>();
//
//       if (androidPlugin != null) {
//         // Create all channels
//         await androidPlugin.createNotificationChannel(fajrChannel);
//         await androidPlugin.createNotificationChannel(otherNamazChannel);
//         await androidPlugin.createNotificationChannel(generalChannel);
//
//         print('✅ All notification channels created successfully');
//       }
//     } catch (e) {
//       print('❌ Error creating notification channels: $e');
//     }
//   }
//
//   static Future<void> initialize({required String currentUserId, required String collectionName}) async {
//     // await Firebase.initializeApp();
//
//     await _instance._requestPermission();
//
//     // Initialize local notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final DarwinInitializationSettings initializationSettingsDarwin =
//     DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsDarwin,
//     );
//
//     await _instance._flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         // Handle notification tapped logic here
//       },
//     );
//
//     FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
//
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _instance._showLocalNotificationFromRemote(message);
//     });
//
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // handle when user taps the notification
//     });
//
//     // Save token
//     final token = await _instance._messaging.getToken();
//     if (token != null && currentUserId.isNotEmpty) {
//       // Determine collection by role later; for now store under users collection
//       await FirebaseFirestore.instance.collection(collectionName).doc(currentUserId).set({
//         'fcmToken': token,
//       }, SetOptions(merge: true));
//     }
//
//     _instance._messaging.onTokenRefresh.listen((newToken) async {
//       if (currentUserId.isNotEmpty) {
//         await FirebaseFirestore.instance.collection(collectionName).doc(currentUserId).set({
//           'fcmToken': newToken,
//         }, SetOptions(merge: true));
//       }
//     });
//   }
//
//   Future<void> _requestPermission() async {
//     try {
//       // 🔹 Request iOS & Android FCM permissions
//       NotificationSettings settings = await _messaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//         provisional: false,
//       );
//
//       debugPrint('🔔 FCM Permission Status: ${settings.authorizationStatus}');
//
//       // 🔹 Additional handling for Android 13+ (API level 33+)
//       if (Platform.isAndroid) {
//         final androidInfo = await DeviceInfoPlugin().androidInfo;
//         if (androidInfo.version.sdkInt >= 33) {
//           final status = await Permission.notification.status;
//
//           if (status.isDenied) {
//             // Request the POST_NOTIFICATIONS permission
//             final result = await Permission.notification.request();
//
//             if (result.isGranted) {
//               debugPrint('✅ Android 13+ notification permission granted.');
//             } else {
//               debugPrint('🚫 Android 13+ notification permission denied.');
//             }
//           } else if (status.isPermanentlyDenied) {
//             debugPrint('⚠️ Notification permission permanently denied.');
//             await openAppSettings();
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('❌ Error requesting notification permission: $e');
//     }
//   }
//
//
//
//
//   Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
//     final notification = message.notification;
//     AndroidNotification? android = message.notification?.android;
//     print("Notification title:-${notification?.title}");
//     print("Notification body:-${notification?.body}");
//     print("Notification dara:-${message.data}");
//     String namazName0='fajr';
//     String  namazName1 = "duhur" ;
//     String  namazName2 = "asr" ;
//     String namazName3 = "magrib" ;
//     String namazName4 = "isha";
//     bool soundtype=false;
//     // Get data from FCM message
//     String namazName ="" ; //message.data['namazName']?.toLowerCase() ?? '';
//     String azaanTime = "azaantime";
//     // 🔥 DEFAULT sound
//     String selectedSound = "alert_sound1";
//     String channelName = "rafahiya_channel_general_V2";
//     String channelName2 = "";
//     String channelDescription = "";
//     print("Notification 1 :-${notification?.title?.toLowerCase().toString().contains(namazName0)}");
//     print("Notification 2 :-${ notification?.title?.toLowerCase().toString().contains(azaanTime)}");
//     print("Notification 3 :-${ notification?.title?.toLowerCase().toString().contains(namazName1)}");
//     String title = message.notification?.title?.toLowerCase() ?? "";
//     title = title.replaceAll(" ", ""); // remove spaces like: "duhur-azaantime"
//     String azaanTime2 = "azaantime";
//     bool isMatch = title.contains(azaanTime2);
//     print("Title: $title");
//     print("Matched: $isMatch");
//     // 🔥 SOUND CHANGE LOGIC
//     if (notification?.title?.toLowerCase().toString().contains(namazName0) == true &&  title.contains(azaanTime2)==true) {
//       print("Notification title fajr ka azaan->>>>}");
//       namazName='fajr';
//       soundtype=true;
//       channelName = "rafahiya_channel_fajr_V2";
//       channelName2 = "Fajr Azaan Notifications_V2";
//       channelDescription = "Channel for Fajr prayer notifications_V2";
//       selectedSound = "alert_sound1";
//     } else if (notification?.title?.toLowerCase().toString().contains(namazName1) == true && title.contains(azaanTime2)==true||
//         notification?.title?.toLowerCase().toString().contains(namazName2) == true&& title.contains(azaanTime2)==true ||
//         notification?.title?.toLowerCase().toString().contains(namazName3) == true && title.contains(azaanTime2)==true||
//         notification?.title?.toLowerCase().toString().contains(namazName4) == true&& title.contains(azaanTime2)==true) {
//
//       print("Notification title duhur ka  azaan ->>>>");
//
//       namazName ="duhur";
//       channelName = "rafahiya_channel_other_V2";
//       channelName2 = "Other Namaz Notifications_V2";
//       channelDescription = "Channel for Duhur, Asr, Magrib, Isha notifications_V2";
//       soundtype=true;
//       channelName = "rafahiya_channel_other_V2";
//       selectedSound = "alert_sound";
//     }else{
//       print("Notification title  default ->>>>");
//       channelName = "rafahiya_channel_general_V2";
//       channelName2 = "General Notifications_V2";
//       channelDescription = "Channel for general notifications without sound_V2";
//       soundtype = false;
//     }
//     // 🔹 Android)
//     final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       android?.channelId??channelName,
//       channelName2,
//       channelDescription: channelDescription,
//       importance: Importance.max,
//       priority: Priority.high,
//       sound: soundtype ? RawResourceAndroidNotificationSound(selectedSound) : null,
//       playSound: true,
//       channelShowBadge: true,
//       visibility: NotificationVisibility.public,
//       showWhen: true,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
//
//     final platform = NotificationDetails(android: androidDetails, iOS: iosDetails);
//
//     await _flutterLocalNotificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch.remainder(100000),
//       notification?.title ?? 'RafahiyaTourism',
//       notification?.body ?? '',
//       platform,
//       payload: message.data.toString(),
//     );
//
//
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
//   print("Notification title:-${message.notification?.title}");
//   print("Notification body:-${message.notification?.body}");
//   print("Notification body:-${message.data}");
//   AndroidNotification? android = message.notification?.android;
//   await Firebase.initializeApp();
//   final fln = FlutterLocalNotificationsPlugin();
//   const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
//   const initSettings = InitializationSettings(android: androidInit);
//   await fln.initialize(initSettings);
//   String namazName0='fajr';
//   String  namazName1 = "duhur" ;
//   String  namazName2 = "asr" ;
//   String namazName3 = "magrib" ;
//   String namazName4 = "isha";
//   bool soundtype=false;
//   // Get data from FCM message
//   // 🔥 DEFAULT sound
//   String selectedSound = "alert_sound1";
//   String channelName = "rafahiya_channel_general_V2";
//   String channelName2 = "";
//   String channelDescription = "";
//   print("Notification 1 :-${message.notification?.title?.toLowerCase().toString().contains(namazName0)}");
//   print("Notification 3 :-${ message.notification?.title?.toLowerCase().toString().contains(namazName1)}");
//   String title = message.notification?.title?.toLowerCase() ?? "";
//   title = title.replaceAll(" ", ""); // remove spaces like: "duhur-azaantime"
//   String azaanTime2 = "azaantime";
//   bool isMatch = title.contains(azaanTime2);
//   print("Title: $title");
//   print("Matched: $isMatch");
//   // 🔥 SOUND CHANGE LOGIC
//   if (message.notification?.title?.toLowerCase().toString().contains(namazName0) == true &&  title.contains(azaanTime2)==true) {
//     print("Notification title fajr ka azaan->>>>");
//     soundtype=true;
//     channelName = "rafahiya_channel_fajr_V2";
//     channelName2 = "Fajr Azaan Notifications_V2";
//     channelDescription = "Channel for Fajr prayer notifications_V2";
//     selectedSound = "alert_sound1";
//   } else if (message.notification?.title?.toLowerCase().toString().contains(namazName1) == true && title.contains(azaanTime2)==true||
//       message.notification?.title?.toLowerCase().toString().contains(namazName2) == true&& title.contains(azaanTime2)==true ||
//       message.notification?.title?.toLowerCase().toString().contains(namazName3) == true && title.contains(azaanTime2)==true||
//       message.notification?.title?.toLowerCase().toString().contains(namazName4) == true&& title.contains(azaanTime2)==true) {
//     print("Notification title duhur ka  azaan ->>>>");
//     channelName = "rafahiya_channel_other_V2";
//     channelName2 = "Other Namaz Notifications_V2";
//     channelDescription = "Channel for Duhur, Asr, Magrib, Isha notifications_V2";
//     soundtype=true;
//     channelName = "rafahiya_channel_other_V2";
//     selectedSound = "alert_sound";
//   }else{
//     print("Notification title  default ->>>>");
//     channelName = "rafahiya_channel_general_V2";
//     channelName2 = "General Notifications_V2";
//     channelDescription = "Channel for general notifications without sound_V2";
//     soundtype = false;
//   }
//
//   // 🔹 Android)
//   final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     android?.channelId??channelName,
//     channelName2,
//     channelDescription: channelDescription,
//     importance: Importance.max,
//     priority: Priority.high,
//     sound: soundtype ? RawResourceAndroidNotificationSound(selectedSound) : null,
//     visibility: NotificationVisibility.public,
//     showWhen: true,
//     playSound: true,
//     channelShowBadge: true,
//   );
//
//   final platform = NotificationDetails(android: androidDetails);
//   await fln.show(
//     DateTime.now().millisecondsSinceEpoch.remainder(100000),
//     message.notification?.title ?? 'RafahiyaTourism',
//     message.notification?.body ?? '',
//     platform,
//     payload: message.data.toString(),
//   );
//
//
// }
