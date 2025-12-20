// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class SelectedMosqueProvider with ChangeNotifier {
//   String? _userId;
//   String? _mosqueUid;
//   String? _mosqueName;
//   String? _mosqueAddress;
//   List<String> _selectedDays = [];
//   Map<String, dynamic> _notificationSettings = {};
//
//   String? get userId => _userId;
//   String? get mosqueUid => _mosqueUid;
//   String? get mosqueName => _mosqueName;
//   String? get mosqueAddress => _mosqueAddress;
//   List<String> get selectedDays => _selectedDays;
//   Map<String, dynamic> get notificationSettings => _notificationSettings;
//
//   SelectedMosqueProvider() {
//     _initializeUser();
//   }
//
//   void _initializeUser() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _userId = user.uid;
//       loadFromFirestore();
//     }
//   }
//
//   void setMosque(String uid, String name, String address) {
//     _mosqueUid = uid;
//     _mosqueName = name;
//     _mosqueAddress = address;
//     notifyListeners();
//   }
//
//   void setSelectedDays(List<String> days) {
//     _selectedDays = days;
//     notifyListeners();
//   }
//
//
//   void setNotificationSettings(Map<String, dynamic> settings) {
//     _notificationSettings = settings;
//     notifyListeners();
//   }
//
//   void updateNotificationSetting(String prayerName, String settingType, bool value) {
//     if (!_notificationSettings.containsKey(prayerName)) {
//       _notificationSettings[prayerName] = {};
//     }
//
//     _notificationSettings[prayerName]![settingType] = value;
//     notifyListeners();
//     saveToFirestore();
//   }
//
//
//   Future<void> loadSettingsForMosque(String mosqueUid) async {
//     if (_userId == null) return;
//
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('user_mosque_settings')
//           .doc(_userId)
//           .get();
//
//       if (doc.exists && doc['mosqueUid'] == mosqueUid) {
//         // Only load settings if they belong to the currently selected mosque
//         _selectedDays = List<String>.from(doc['selectedDays'] ?? []);
//         _notificationSettings = Map<String,dynamic>.from(doc['notificationSettings'] ?? {});
//
//         // Initialize default settings if none exist
//         _initializeDefaultSettings();
//
//         notifyListeners();
//       } else {
//         // If no settings exist for this mosque, reset to defaults
//         _selectedDays = [];
//         _initializeDefaultSettings();
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error loading settings for mosque: $e');
//       // Reset to defaults on error
//       _selectedDays = [];
//       _initializeDefaultSettings();
//       notifyListeners();
//     }
//   }
//
//
//   Future<void> saveToFirestore() async {
//     if (_userId == null || _mosqueUid == null) return;
//
//     try {
//       await FirebaseFirestore.instance
//           .collection('user_mosque_settings')
//           .doc(_userId)
//           .set({
//         'userId': _userId,
//         'mosqueUid': _mosqueUid,
//         'mosqueName': _mosqueName,
//         'mosqueAddress': _mosqueAddress,
//         'selectedDays': _selectedDays,
//         'notificationSettings': _notificationSettings,
//         'updatedAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//     } catch (e) {
//       print('Error saving to Firestore: $e');
//     }
//   }
//
// // In SelectedMosqueProvider class
//   void _initializeDefaultSettings() {
//     if (_notificationSettings.isEmpty) {
//       _notificationSettings = {
//         'Fajr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
//         'Dhuhr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
//         'Asr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
//         'Maghrib': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
//         'Isha': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
//         'Jumuah': {'JamatAudio': false, 'JamatText': false},
//         'Announcement': {'JamatAudio': false, 'JamatText': false},
//         'Hadiyah': {'JamatAudio': false, 'JamatText': false},
//         'Sehri/Iftari': {'JamatAudio': false, 'JamatText': false},
//       };
//     }
//   }
//
//   Future<void> loadFromFirestore() async {
//     if (_userId == null) return;
//
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('user_mosque_settings')
//           .doc(_userId)
//           .get();
//
//       if (doc.exists) {
//         _mosqueUid = doc['mosqueUid'];
//         _mosqueName = doc['mosqueName'];
//         _mosqueAddress = doc['mosqueAddress'];
//         _selectedDays = List<String>.from(doc['selectedDays'] ?? []);
//         _notificationSettings = Map<String, dynamic>.from(doc['notificationSettings'] ?? {});
//
//         // Initialize default settings if none exist
//         _initializeDefaultSettings();
//
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error loading from Firestore: $e');
//     }
//   }
// }