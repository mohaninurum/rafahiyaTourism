import 'package:flutter/material.dart';

class NotificationSettingsProvider extends ChangeNotifier {
  final Map<String, bool> _daySelection = {
    "Monday": false,
    "Tuesday": false,
    "Wednesday": false,
    "Thursday": false,
    "Friday": false,
    "Saturday": false,
    "Sunday": false,
  };

  Map<String, bool> get daySelection => _daySelection;

  void updateDaySelection(String day, bool value) {
    _daySelection[day] = value;
    notifyListeners();
  }

  void toggleAllDays(bool selectAll) {
    for (var key in daySelection.keys) {
      daySelection[key] = selectAll;
    }
    notifyListeners();
  }

  List<String> getSelectedDays() {
    return daySelection.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  void setSelectedDays(List<String> days) {
    for (var key in _daySelection.keys) {
      _daySelection[key] = days.contains(key);
    }
    notifyListeners();
  }
}