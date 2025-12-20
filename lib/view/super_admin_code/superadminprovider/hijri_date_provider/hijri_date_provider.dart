import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hijri/hijri_calendar.dart';

class HijriDateProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _selectedCountry;
  DateTime _selectedDate = DateTime.now();
  Map<String, Map<String, dynamic>> _countryDateSettings = {};
  List<String> _availableCountries = [];

  String? get selectedCountry => _selectedCountry;
  DateTime get selectedDate => _selectedDate;
  Map<String, Map<String, dynamic>> get countryDateSettings => _countryDateSettings;
  List<String> get availableCountries => _availableCountries;

  void setCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String toHijri(DateTime date) {
    HijriCalendar hijriDate = HijriCalendar.fromDate(date);
    String monthName = hijriDate.longMonthName;
    return '${hijriDate.hDay} $monthName ${hijriDate.hYear} AH';
  }

  Map<String, dynamic> getHijriDateObject(DateTime date) {
    HijriCalendar hijriDate = HijriCalendar.fromDate(date);
    return {
      'day': hijriDate.hDay,
      'month': hijriDate.hMonth,
      'year': hijriDate.hYear,
      'monthName': hijriDate.longMonthName,
      'fullDate': '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} AH',
      'baseGregorianDate': date,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  Future<void> saveDateSettings() async {
    if (_selectedCountry == null) {
      throw Exception('Please select a country first');
    }

    try {
      final hijriDate = getHijriDateObject(_selectedDate);

      final data = {
        'country': _selectedCountry,
        'gregorianDate': _selectedDate,
        'hijriDate': hijriDate,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('hijri_date_settings')
          .doc(_selectedCountry)
          .set(data, SetOptions(merge: true));

      _countryDateSettings[_selectedCountry!] = data;
    } catch (e) {
      throw Exception('Failed to save date settings: $e');
    }
  }

  Future<void> loadDateSettings(String country) async {
    try {
      final doc = await _firestore
          .collection('hijri_date_settings')
          .doc(country)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['gregorianDate'] != null) {
          if (data['gregorianDate'] is Timestamp) {
            final timestamp = data['gregorianDate'] as Timestamp;
            _selectedDate = timestamp.toDate();
          } else if (data['gregorianDate'] is DateTime) {
            _selectedDate = data['gregorianDate'] as DateTime;
          }
        }

        if (data['hijriDate'] != null) {
          final hijriDate = data['hijriDate'] as Map<String, dynamic>;
          if (hijriDate['baseGregorianDate'] != null && hijriDate['baseGregorianDate'] is Timestamp) {
            final timestamp = hijriDate['baseGregorianDate'] as Timestamp;
            hijriDate['baseGregorianDate'] = timestamp.toDate();
          }
        }

        _selectedCountry = country;
        _countryDateSettings[country] = data;

        // 🔹 Automatically check if we need to update the date
        await checkAndAutoUpdateDate(country);

        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to load date settings: $e');
    }
  }

  // ✅ NEW: Automatically move to the next Hijri date if a new Gregorian day has started
  Future<void> checkAndAutoUpdateDate(String country) async {
    if (!_countryDateSettings.containsKey(country)) return;

    final countryData = _countryDateSettings[country]!;
    final hijriData = countryData['hijriDate'] as Map<String, dynamic>;
    final baseDate = hijriData['baseGregorianDate'];

    DateTime? baseGregorian;
    if (baseDate is Timestamp) {
      baseGregorian = baseDate.toDate();
    } else if (baseDate is DateTime) {
      baseGregorian = baseDate;
    }

    if (baseGregorian == null) return;

    final now = DateTime.now();
    final baseDay = DateTime(baseGregorian.year, baseGregorian.month, baseGregorian.day);
    final today = DateTime(now.year, now.month, now.day);

    final daysDiff = today.difference(baseDay).inDays;

    if (daysDiff > 0) {
      print('Auto-updating Hijri date for $country (+$daysDiff days)');

      // Calculate new Hijri date
      final newHijri = _calculateProgressedHijriDate(hijriData, daysDiff);

      // Update Firestore with the new date
      final updatedData = {
        'country': country,
        'gregorianDate': now,
        'hijriDate': {
          ...newHijri,
          'baseGregorianDate': now,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('hijri_date_settings')
          .doc(country)
          .set(updatedData, SetOptions(merge: true));

      _countryDateSettings[country] = updatedData;
      notifyListeners();

      print('✅ Hijri date for $country updated to ${newHijri['fullDate']}');
    } else {
      print('No date update needed for $country — same day.');
    }
  }

  Future<void> loadCountriesFromSubAdmins() async {
    try {
      final querySnapshot = await _firestore
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      final countries = <String>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final country = _extractCountryFromSubAdmin(data);
        if (country != null && country.isNotEmpty) {
          countries.add(country);
        }
      }

      _availableCountries = countries.toList()..sort();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load countries from sub-admins: $e');
    }
  }

  String? _extractCountryFromSubAdmin(Map<String, dynamic> data) {
    if (data['location'] != null && data['location'] is Map<String, dynamic>) {
      final location = data['location'] as Map<String, dynamic>;
      if (location['country'] != null) return location['country'].toString();
    }

    if (data['address'] != null) {
      final address = data['address'].toString();
      final country = _extractCountryFromAddress(address);
      if (country != null) return country;
    }

    if (data['city'] != null) return data['city'].toString();
    return null;
  }

  String? _extractCountryFromAddress(String address) {
    final commonCountries = [
      'Saudi Arabia', 'United Arab Emirates', 'Qatar', 'Kuwait', 'Germany',
      'Oman', 'Bahrain', 'Egypt', 'Jordan', 'Palestine', 'Morocco', 'Turkey',
      'Indonesia', 'Malaysia', 'Pakistan', 'India', 'Bangladesh'
    ];

    for (final country in commonCountries) {
      if (address.toLowerCase().contains(country.toLowerCase())) {
        return country;
      }
    }
    return null;
  }

  Future<void> loadAllCountryDateSettings() async {
    try {
      final querySnapshot = await _firestore.collection('hijri_date_settings').get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final country = data['country'] as String;

        if (data['hijriDate'] != null) {
          final hijriDate = data['hijriDate'] as Map<String, dynamic>;
          if (hijriDate['baseGregorianDate'] != null && hijriDate['baseGregorianDate'] is Timestamp) {
            final timestamp = hijriDate['baseGregorianDate'] as Timestamp;
            hijriDate['baseGregorianDate'] = timestamp.toDate();
          }
        }

        _countryDateSettings[country] = data;

        // 🔹 Automatically check each country’s date
        await checkAndAutoUpdateDate(country);
      }

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load country date settings: $e');
    }
  }

  Map<String, dynamic> getHijriDateForMosque(String mosqueId, Map<String, dynamic>? mosqueData) {
    final now = DateTime.now();
    final country = _extractCountryFromSubAdmin(mosqueData ?? {});
    if (country == null || country.isEmpty) return _getDefaultHijriDate(now);
    return getCurrentHijriDateForCountry(country);
  }

  Map<String, dynamic> getCurrentHijriDateForCountry(String country) {
    final now = DateTime.now();
    if (!_countryDateSettings.containsKey(country)) {
      return _getDefaultHijriDate(now);
    }

    final countryData = _countryDateSettings[country]!;
    final hijriDateData = countryData['hijriDate'] as Map<String, dynamic>;

    if (hijriDateData['baseGregorianDate'] == null) {
      return hijriDateData;
    }

    DateTime baseGregorianDate;
    final baseDate = hijriDateData['baseGregorianDate'];

    if (baseDate is Timestamp) {
      baseGregorianDate = baseDate.toDate();
    } else if (baseDate is DateTime) {
      baseGregorianDate = baseDate;
    } else {
      return hijriDateData;
    }

    final localNow = DateTime.now().toLocal();
    final localBaseDate = baseGregorianDate.toLocal();

    final daysDifference = localNow
        .difference(DateTime(localBaseDate.year, localBaseDate.month, localBaseDate.day))
        .inDays;

    if (daysDifference == 0) {
      return hijriDateData;
    }

    return _calculateProgressedHijriDate(hijriDateData, daysDifference);
  }

  Map<String, dynamic> _getDefaultHijriDate(DateTime date) {
    final hijriDate = HijriCalendar.fromDate(date);
    return {
      'day': hijriDate.hDay,
      'month': hijriDate.hMonth,
      'year': hijriDate.hYear,
      'monthName': hijriDate.longMonthName,
      'fullDate': '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} AH',
    };
  }

  Map<String, dynamic> _calculateProgressedHijriDate(
      Map<String, dynamic> baseHijriDate, int daysDifference) {
    int day = baseHijriDate['day'] as int;
    int month = baseHijriDate['month'] as int;
    int year = baseHijriDate['year'] as int;

    day += daysDifference;

    while (day > 30) {
      day -= 30;
      month += 1;
      if (month > 12) {
        month = 1;
        year += 1;
      }
    }

    final monthName = _getHijriMonthName(month);
    final fullDate = '$day $monthName $year AH';

    return {
      'day': day,
      'month': month,
      'year': year,
      'monthName': monthName,
      'fullDate': fullDate,
    };
  }

  String _getHijriMonthName(int month) {
    switch (month) {
      case 1:
        return 'Muharram';
      case 2:
        return 'Safar';
      case 3:
        return 'Rabi al-Awwal';
      case 4:
        return 'Rabi al-Thani';
      case 5:
        return 'Jumada al-Awwal';
      case 6:
        return 'Jumada al-Thani';
      case 7:
        return 'Rajab';
      case 8:
        return 'Sha\'ban';
      case 9:
        return 'Ramadan';
      case 10:
        return 'Shawwal';
      case 11:
        return 'Dhu al-Qi\'dah';
      case 12:
        return 'Dhu al-Hijjah';
      default:
        return 'Unknown';
    }
  }
}
