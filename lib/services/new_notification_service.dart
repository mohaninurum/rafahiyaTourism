



// notification_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'new_notification_service.dart';

class NewNotificationService {
  NewNotificationService._();
  static final NewNotificationService _instance = NewNotificationService._();
  factory NewNotificationService() => _instance;

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;

  // Initialize with currentUserId and role collection name (users/subAdmin/super_admins)
  static Future<void> initialize({
    required String currentUserId,
    required String collectionName, // e.g., "users" or "subAdmin" or "super_admins"
    required String role, // "user", "subadmin", "super_admin"
  }) async {
    await _instance._requestPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _instance._flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // handle tap
      },
    );



    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _instance._showLocalNotificationFromRemote(message);
      // _instance.saveMessageToFirestore(message, role, currentUserId);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // handle when user taps the notification
      // _instance.saveMessageToFirestore(message, role, currentUserId);
    });

    // Save token
    final token = await _instance._messaging.getToken();
    if (token != null && currentUserId.isNotEmpty) {
      // store player token or fcm token in the role collection
      await FirebaseFirestore.instance.collection(collectionName).doc(currentUserId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }

    _instance._messaging.onTokenRefresh.listen((newToken) async {
      if (currentUserId.isNotEmpty) {
        await FirebaseFirestore.instance.collection(collectionName).doc(currentUserId).set({
          'fcmToken': newToken,
        }, SetOptions(merge: true));
      }
    });
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
            if (result.isGranted) {
              debugPrint('✅ Android 13+ notification permission granted.');
            } else {
              debugPrint('🚫 Android 13+ notification permission denied.');
            }
          } else if (status.isPermanentlyDenied) {
            debugPrint('⚠️ Notification permission permanently denied.');
            await openAppSettings();
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
    }
  }

  Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    print("Notification title:-${notification?.title}");
    print("Notification body:-${notification?.body}");
    print("Notification dara:-${message.data}");
    print("andriod channel id:-${android?.channelId}");


    bool soundtype=false;
    String selectedSound = "alert_sound1";
    String channelName = "rafahiya_channel_general_V3";
    String channelName2 = "Fajr Azaan Notifications_V3";
    String channelDescription = "Channel for Fajr prayer notifications_V3";

    if (android?.channelId=="rafahiya_channel_fajr_V3") {
      print("Notification title  fajr ->>>>");
      soundtype=true;
      channelName2 = "Fajr Azaan Notifications_V3";
      channelDescription = "Channel for Fajr prayer notifications_V3";
      selectedSound = "alert_sound1";
    } else if (android?.channelId=="rafahiya_channel_other_V3"){
      print("Notification title  other ->>>>");
      channelName2 = "Other Namaz Notifications_V3";
      channelDescription = "Channel for Duhur, Asr, Magrib, Isha notifications_V3";
      soundtype=true;
      selectedSound = "alert_sound";
    }else{
      print("Notification title  default ->>>>");
      channelName2 = "General Notifications_V3";
      channelDescription = "Channel for general notifications without sound_V3";
      soundtype = false;
    }
    // 🔹 Android)
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      android?.channelId??channelName,
      channelName2,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      sound: soundtype ? RawResourceAndroidNotificationSound(selectedSound) : null,
      playSound: true,
      channelShowBadge: true,
      visibility: NotificationVisibility.public,
      showWhen: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    final platform = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      notification?.title ?? 'RafahiyaTourism',
      notification?.body ?? '',
      platform,
      payload: message.data.toString(),
    );


  }
}

// Save remote message to Firestore notifications collection (so UI screens can query)
Future<void> saveMessageToFirestore(RemoteMessage message, String role, String currentUserId) async {
  try {
    final firestore = FirebaseFirestore.instance;
    final Map<String, dynamic> data = {};

    // message.notification might be null; prefer message.data to carry structured info
    final String title = message.notification?.title ?? message.data['title'] ?? '';
    final String msg = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? '';

    data['title'] = title;
    data['message'] = msg;
    data['type'] = message.data['type'] ?? '';
    data['senderRole'] = message.data['senderRole'] ?? null;
    data['receiverRole'] = message.data['receiverRole'] ?? role; // fallback to current role
    data['receiverId'] = message.data['receiverId'] ?? (message.data['targetUserId'] ?? null);
    data['extraData'] = message.data;
    data['timestamp'] = FieldValue.serverTimestamp();
    data['readBy'] = {};

    // If message is targeted to specific receiverId and it doesn't match currentUserId, don't store locally.
    final receiverId = data['receiverId'];
    if (receiverId != null && receiverId != '' && receiverId != currentUserId) {
      // Not intended for this user
    } else {
      await firestore.collection('notifications').add(data);
    }
  } catch (e) {
    debugPrint("❌ Error saving message to Firestore: $e");
  }
}


@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  AndroidNotification? android = message.notification?.android;
  print("Notification title:-${message.notification?.title}");
  print("Notification body:-${message.notification?.body}");
  print("Notification body:-${message.data}");
  print("andriod channel id:-${android?.channelId}");
  await Firebase.initializeApp();
  final fln = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await fln.initialize(initSettings);


  bool soundtype=false;
  String selectedSound = "alert_sound1";
  String channelName = "rafahiya_channel_general_V3";
  String channelName2 = "Fajr Azaan Notifications_V3";
  String channelDescription = "Channel for Fajr prayer notifications_V3";

  if (android?.channelId=="rafahiya_channel_fajr_V3") {
    print("Notification title  fajr ->>>>");
    soundtype=true;
    channelName2 = "Fajr Azaan Notifications_V3";
    channelDescription = "Channel for Fajr prayer notifications_V3";
    selectedSound = "alert_sound1";
  } else if (android?.channelId=="rafahiya_channel_other_V3"){
    print("Notification title  other ->>>>");
    channelName2 = "Other Namaz Notifications_V3";
    channelDescription = "Channel for Duhur, Asr, Magrib, Isha notifications_V3";
    soundtype=true;
    selectedSound = "alert_sound";
  }else{
    print("Notification title  default ->>>>");
    channelName2 = "General Notifications_V3";
    channelDescription = "Channel for general notifications without sound_V3";
    soundtype = false;
  }

  // 🔹 Android)
  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    android?.channelId??channelName,
    channelName2,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.max,
    sound: soundtype ? RawResourceAndroidNotificationSound(selectedSound) : null,
    playSound: true,
    channelShowBadge: true,
    visibility: NotificationVisibility.public,
    showWhen: true,
  );
  final platform = NotificationDetails(android: androidDetails);
  await fln.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    message.notification?.title ?? 'RafahiyaTourism',
    message.notification?.body ?? '',
    platform,
    payload: message.data.toString(),
  );

  // Save to Firestore from background - note: Firebase must be initialized in background isolate in real project

}
