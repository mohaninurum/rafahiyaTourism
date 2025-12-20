import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrayerTimesProvider with ChangeNotifier {
  String? fajr;
  String? dhuhr;
  String? asr;
  String? maghrib;
  String? isha;
  String? zawal = '12:00 PM';

  bool isLoading = true;

  Future<void> fetchPrayerTimes({
    String city = "Delhi",
    String country = "India",
    int method = 2,
  }) async {
    try {
      final url =
          'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=$method';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        fajr = timings['Fajr'];
        dhuhr = timings['Dhuhr'];
        asr = timings['Asr'];
        maghrib = timings['Maghrib'];
        isha = timings['Isha'];
      }
    } catch (e) {
      print('Error fetching prayer times: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
