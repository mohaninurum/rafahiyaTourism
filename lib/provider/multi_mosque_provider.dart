import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MultiMosqueProvider with ChangeNotifier {
  String? _userId;
  Map<int, Map<String, dynamic>> _mosqueSelections = {};
  Map<int, List<String>> _selectedDays = {};
  Map<int, Map<String, dynamic>> _notificationSettings = {};

  String? get userId => _userId;

  MultiMosqueProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      loadFromFirestore();
    }
  }

  void setMosqueData(int tabIndex, Map<String, dynamic> mosqueData) {
    _mosqueSelections[tabIndex] = mosqueData;
    notifyListeners();
    saveToFirestore();
  }


  Map<String, dynamic>? getMosqueData(int tabIndex) {
    return _mosqueSelections[tabIndex];
  }

  // Get selected days for a specific tab
  List<String> getSelectedDays(int tabIndex) {
    return _selectedDays[tabIndex] ?? [];
  }

  // Get notification settings for a specific tab
  Map<String, dynamic> getNotificationSettings(int tabIndex) {
    return _notificationSettings[tabIndex] ?? {};
  }

  // Set mosque for a specific tab
  void setMosque(int tabIndex, String uid, String name, String address) {
    _mosqueSelections[tabIndex] = {
      'uid': uid,
      'name': name,
      'address': address,
    };
    notifyListeners();
  }

  // Set selected days for a specific tab
  void setSelectedDays(int tabIndex, List<String> days) {
    _selectedDays[tabIndex] = days;
    notifyListeners();
  }

  // Update notification setting for a specific tab
  void updateNotificationSetting(int tabIndex, String prayerName, String settingType, bool value) {
    if (!_notificationSettings.containsKey(tabIndex)) {
      _notificationSettings[tabIndex] = {};
    }

    if (!_notificationSettings[tabIndex]!.containsKey(prayerName)) {
      _notificationSettings[tabIndex]![prayerName] = {};
    }

    _notificationSettings[tabIndex]![prayerName]![settingType] = value;
    notifyListeners();
    saveToFirestore();
  }

  // Convert integer keys to string keys for Firestore
  Map<String, dynamic> _convertIntKeysToString(Map<int, dynamic> map) {
    return map.map((key, value) => MapEntry(key.toString(), value));
  }

  // Convert string keys back to integer keys when loading from Firestore
  Map<int, dynamic> _convertStringKeysToInt(Map<String, dynamic> map) {
    final result = <int, dynamic>{};
    map.forEach((key, value) {
      try {
        result[int.parse(key)] = value;
      } catch (e) {
        print('Error parsing key $key to int: $e');
      }
    });
    return result;
  }

  // Helper method to convert dynamic list to String list
  List<String> _convertDynamicListToStringList(List<dynamic> dynamicList) {
    return dynamicList.map((item) => item.toString()).toList();
  }

  // Load from Firestore
  Future<void> loadFromFirestore() async {
    if (_userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_mosque_settings')
          .doc(_userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        // Load mosque selections (convert string keys back to int)
        if (data['mosqueSelections'] != null) {
          final mosqueSelectionsMap = Map<String, dynamic>.from(data['mosqueSelections']);
          _mosqueSelections = _convertStringKeysToInt(mosqueSelectionsMap).cast<int, Map<String, dynamic>>();
        }

        // Load selected days (convert string keys back to int and dynamic list to String list)
        if (data['selectedDays'] != null) {
          final selectedDaysMap = Map<String, dynamic>.from(data['selectedDays']);
          final convertedMap = _convertStringKeysToInt(selectedDaysMap);

          _selectedDays = convertedMap.map((key, value) {
            if (value is List<dynamic>) {
              return MapEntry(key, _convertDynamicListToStringList(value));
            }
            return MapEntry(key, <String>[]);
          });
        }

        // Load notification settings (convert string keys back to int)
        if (data['notificationSettings'] != null) {
          final notificationSettingsMap = Map<String, dynamic>.from(data['notificationSettings']);
          _notificationSettings = _convertStringKeysToInt(notificationSettingsMap).cast<int, Map<String, dynamic>>();
        }

        notifyListeners();
      }
    } catch (e) {
      print('Error loading from Firestore: $e');
    }
  }

  void initializeDefaultSettings(int tabIndex) {
    if (!_notificationSettings.containsKey(tabIndex) || _notificationSettings[tabIndex]!.isEmpty) {
      _notificationSettings[tabIndex] = {
        'Fajr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
        'Dhuhr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
        'Asr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
        'Maghrib': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
        'Isha': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
        'Jumuah': {'JamatAudio': false, 'JamatText': false},
        'Hadiyah': {'JamatAudio': false, 'JamatText': false},
        'Announcement': {'JamatAudio': false, 'JamatText': false},
        'Sehri/Iftari': {'JamatAudio': false, 'JamatText': false},
      };
      notifyListeners();
      saveToFirestore();
    }
  }
  Future<void> saveToFirestore() async {
    if (_userId == null) return;

    try {
      // Convert integer keys to string keys for Firestore compatibility
      final mosqueSelectionsForFirestore = _convertIntKeysToString(_mosqueSelections);
      final selectedDaysForFirestore = _convertIntKeysToString(_selectedDays);
      final notificationSettingsForFirestore = _convertIntKeysToString(_notificationSettings);

      await FirebaseFirestore.instance
          .collection('user_mosque_settings')
          .doc(_userId)
          .set({
        'userId': _userId,
        'mosqueSelections': mosqueSelectionsForFirestore,
        'selectedDays': selectedDaysForFirestore,
        'notificationSettings': notificationSettingsForFirestore,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving to Firestore: $e');
    }
  }
}