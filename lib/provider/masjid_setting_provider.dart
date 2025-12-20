import 'package:flutter/material.dart';

class MasjidSettingsProvider extends ChangeNotifier {
  final Map<String, Map<String, bool>> _notificationSettings = {
    'Fajr': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
    'Zohar': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
    'Asar': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
    'Maghrib': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
    'Isha': {'AzanAudio': false, 'AzanText': false, 'JamatAudio': false, 'JamatText': false},
    'Announcement': {}, // No checkboxes for Announcement
    'Hadiyah': {'Text': false}, // Only text notification for Hadiyah
    'Sehri/Iftari': {'Audio': false, 'Text': false}, // Both audio and text for Sehri/Iftari
  };

  Map<String, Map<String, bool>> get notificationSettings => _notificationSettings;

  void updateSetting(String prayer, String type, bool value) {
    if (_notificationSettings[prayer] != null) {
      _notificationSettings[prayer]![type] = value;
      notifyListeners();
    }
  }

  bool hasAnySettingEnabled(String prayer) {
    if (!_notificationSettings.containsKey(prayer)) {
      return false;
    }

    // For Announcement which has no settings, return false
    if (_notificationSettings[prayer]!.isEmpty) {
      return false;
    }

    return _notificationSettings[prayer]!.values.any((enabled) => enabled);
  }
}