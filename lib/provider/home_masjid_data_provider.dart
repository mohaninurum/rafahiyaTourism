




import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeMasjidDataProvider with ChangeNotifier {
  String? _userId;
  final Map<int, Map<String, dynamic>> _mosqueData = {};
  final Map<int, Map<String, dynamic>> _specialNamazTimes = {};
  final Map<int, Map<String, dynamic>> _prayerTimes = {};
  final Map<int, bool> _isLoading = {};
  final Map<int, String?> _errors = {};
  final Map<int, Map<String, Map<String, String>>> _eidTimes = {};
  String? get userId => _userId;
  final Map<int, Map<String, Map<String, String>>> _jumuahTimes = {};
  final Map<int, Map<String, String>> _ramadanTimes = {};
  final Map<int, Map<String, String>> _sunsetTimes = {};
  final Map<int, Map<String, String>> _prohibitedTimes = {};
  final Map<int, List<Map<String, dynamic>>> _hadiyaDetails = {};
  final Map<int, List<Map<String, dynamic>>> _bayanData = {};

  // NEW: Store last update dates for different sections
  final Map<int, DateTime?> _lastNamazUpdateTime = {};
  final Map<int, DateTime?> _lastJumuahUpdateTime = {};
  final Map<int, DateTime?> _lastRamadanUpdateTime = {};
  final Map<int, DateTime?> _lastGeneralUpdateTime = {}; // To get the absolute most recent update if needed

  final Map<int, List<StreamSubscription>> _subscriptions = {};

  HomeMasjidDataProvider() {
    _initializeUser();
  }

  void _initializeUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
    }
  }

  Map<String, dynamic>? getMosqueData(int tabIndex) {
    return _mosqueData[tabIndex];
  }

  Map<String, Map<String, String>>? getEidTimes(int tabIndex) {
    return _eidTimes[tabIndex];
  }

  Map<String, String>? getRamadanTimes(int tabIndex) {
    return _ramadanTimes[tabIndex];
  }

  Map<String, String>? getSunsetTimes(int tabIndex) {
    return _sunsetTimes[tabIndex];
  }

  List<Map<String, dynamic>>? getHadiyaDetails(int tabIndex) {
    return _hadiyaDetails[tabIndex];
  }

  List<Map<String, dynamic>>? getBayanData(int tabIndex) {
    return _bayanData[tabIndex];
  }

  Map<String, String>? getProhibitedTimes(int tabIndex) {
    return _prohibitedTimes[tabIndex];
  }

  Map<String, dynamic>? getPrayerTimes(int tabIndex) {
    return _prayerTimes[tabIndex];
  }

  Map<String, Map<String, String>>? getJumuahTimes(int tabIndex) {
    return _jumuahTimes[tabIndex];
  }

  bool isLoading(int tabIndex) {
    return _isLoading[tabIndex] ?? false;
  }

  Map<String, dynamic>? getSpecialNamazTimes(int tabIndex) {
    return _specialNamazTimes[tabIndex];
  }

  String? getError(int tabIndex) {
    return _errors[tabIndex];
  }

  // NEW: Getters for last update times
  DateTime? getLastNamazUpdateTime(int tabIndex) => _lastNamazUpdateTime[tabIndex];
  DateTime? getLastJumuahUpdateTime(int tabIndex) => _lastJumuahUpdateTime[tabIndex];
  DateTime? getLastRamadanUpdateTime(int tabIndex) => _lastRamadanUpdateTime[tabIndex];
  DateTime? getLastGeneralUpdateTime(int tabIndex) => _lastGeneralUpdateTime[tabIndex];


  String _extractCleanAddress(String fullAddress) {
    try {
      if (fullAddress.contains(',')) {
        final parts = fullAddress.split(',');

        if (parts.length > 1) {
          final cleanParts = parts.sublist(1);
          return cleanParts.join(',').trim();
        }
      }
      return fullAddress;
    } catch (e) {
      return fullAddress;
    }
  }
  Future<void> _fetchHadiyaDetails(int tabIndex, String mosqueUid) async {
    try {
      final hadiyaSnapshot = await FirebaseFirestore.instance
          .collection('mosques')
          .doc(mosqueUid)
          .collection('hadiyaDetails')
          .where('allowed', isEqualTo: true)
          .get();

      if (hadiyaSnapshot.docs.isNotEmpty) {
        final List<Map<String, dynamic>> hadiyaList = [];

        for (var doc in hadiyaSnapshot.docs) {
          final hadiyaData = doc.data();
          hadiyaData['id'] = doc.id;
          hadiyaList.add(hadiyaData);
        }

        _hadiyaDetails[tabIndex] = hadiyaList;
        if (kDebugMode) {
          print('Fetched ${hadiyaList.length} allowed hadiya details for mosque $mosqueUid');
        }
      } else {
        _hadiyaDetails[tabIndex] = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Hadiya details: $e');
      }
      _hadiyaDetails[tabIndex] = [];
    }
  }



  void _cancelSubscriptions(int tabIndex) {
    if (_subscriptions.containsKey(tabIndex)) {
      for (var subscription in _subscriptions[tabIndex]!) {
        subscription.cancel();
      }
      _subscriptions.remove(tabIndex);
    }
  }

  Future<void> fetchMosqueData(int tabIndex, String? mosqueUid) async {
    if (mosqueUid == null || mosqueUid.isEmpty) {
      _clearData(tabIndex);
      _errors[tabIndex] = 'No mosque selected';
      notifyListeners();
      return;
    }

    // Cancel existing subscriptions for this tab
    _cancelSubscriptions(tabIndex);

    _isLoading[tabIndex] = true;
    _errors[tabIndex] = null;
    notifyListeners();

    try {
      // Set up real-time listener for mosque data
      final mosqueStream = FirebaseFirestore.instance
          .collection('subAdmin')
          .doc(mosqueUid)
          .snapshots();

      var subscription = mosqueStream.listen((mosqueDoc) {
        if (mosqueDoc.exists) {
          _processMosqueData(tabIndex, mosqueUid, mosqueDoc.data()!);
        } else {
          _errors[tabIndex] = 'Mosque data not found';
          _clearData(tabIndex);
          notifyListeners();
        }
      }, onError: (error) {
        _errors[tabIndex] = 'Error fetching mosque data: $error';
        _clearData(tabIndex);
        notifyListeners();
      });

      _subscriptions[tabIndex] = [subscription];

    } catch (e) {
      _errors[tabIndex] = 'Error setting up listeners: $e';
      _clearData(tabIndex);
      _isLoading[tabIndex] = false;
      notifyListeners();
    }
  }

  void _processMosqueData(int tabIndex, String mosqueUid, Map<String, dynamic> data) {
    _mosqueData[tabIndex] = {
      'uid': mosqueUid,
      'name': data['masjidName'] ?? '',
      'address': data['address'] ?? '',
      'phone': data['mobileNumber'] ?? '',
      'imamName': data['imamName'] ?? '',
      'masjidPhoneNumber': data['masjidPhoneNumber'] ?? '',
      'city': data['city'] ?? '',
      'pinCode': data['pinCode'] ?? '',
      'location': data['location'] ?? {},
      'successfullyRegistered': data['successfullyRegistered'] ?? false,
    };

    // Set up real-time listeners for all related data
    _setUpRealTimeListeners(tabIndex, mosqueUid);
  }

  void _setUpRealTimeListeners(int tabIndex, String mosqueUid) {
    final subscriptions = _subscriptions[tabIndex] ?? [];


    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('namazTimings')
            .snapshots()
            .listen((snapshot) {
          _processPrayerTimes(tabIndex, snapshot);
          _calculateGeneralLastUpdate(tabIndex); // Calculate general last update
          notifyListeners();
        })
    );

    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('specialTimings')
            .where(FieldPath.documentId, whereIn: ['eidUlFitr'])
            .snapshots()
            .listen((snapshot) {
          _processEidTimes(tabIndex, snapshot);
          _calculateGeneralLastUpdate(tabIndex); // Calculate general last update
          notifyListeners();
        })
    );

    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('namazTimings')
            .where(FieldPath.documentId, whereIn: ['jumajammat1', 'jumajammat2'])
            .snapshots()
            .listen((snapshot) {
          _processJumuahTimes(tabIndex, snapshot);
          _calculateGeneralLastUpdate(tabIndex); // Calculate general last update
          notifyListeners();
        })
    );

    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('specialTimings')
            .where(FieldPath.documentId, whereIn: ['ramzan', 'sunset', 'prohibitedTime', 'specialNamaz'])
            .snapshots()
            .listen((snapshot) {
          _processSpecialTimes(tabIndex, snapshot);
          _calculateGeneralLastUpdate(tabIndex); // Calculate general last update
          notifyListeners();
        })
    );

    // Hadiya Details Listener
    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('hadiyaDetails')
            .where('allowed', isEqualTo: true)
            .snapshots()
            .listen((snapshot) {
          _processHadiyaDetails(tabIndex, snapshot);
          notifyListeners();
        })
    );

    // Bayan Data Listener
    subscriptions.add(
        FirebaseFirestore.instance
            .collection('mosques')
            .doc(mosqueUid)
            .collection('bayan')
            .orderBy('createdAt', descending: true)
            .snapshots()
            .listen((snapshot) {
          _processBayanData(tabIndex, snapshot);
          notifyListeners();
        })
    );

    _subscriptions[tabIndex] = subscriptions;
    _isLoading[tabIndex] = false;
    notifyListeners();
  }

  void _processPrayerTimes(int tabIndex, QuerySnapshot snapshot) {
    final Map<String, dynamic> prayerTimesMap = {};
    DateTime? latestNamazUpdate;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docId = doc.id.toLowerCase();

      if (docId == 'jumajammat1' || docId == 'jumajammat2') {
        continue;
      }

      String prayerName;
      switch (docId) {
        case 'fajr': prayerName = 'Fajr'; break;
        case 'duhur': prayerName = 'Dhuhr'; break;
        case 'asr': prayerName = 'Asr'; break;
        case 'magrib': prayerName = 'Maghrib'; break;
        case 'isha': prayerName = 'Isha'; break;
        default: prayerName = docId;
      }

      prayerTimesMap[prayerName] = {
        'azaanTime': data['azaanTime']?.toString() ?? 'NA',
        'jammatTime': data['jammatTime']?.toString() ?? 'NA',
        'awalTime': data['awwalTime']?.toString() ?? 'NA',
        'akhirTime': data['akhirTime']?.toString() ?? 'NA',
      };
      _specialNamazTimes[tabIndex] = {
        'namaz1Name': 'NA', 'namaz1Time': 'NA',
        'namaz2Name': 'NA', 'namaz2Time': 'NA',
        'namaz3Name': 'NA', 'namaz3Time': 'NA',
        'lastUpdated': 'NA',
        'imamId': 'NA',
      };

      // Extract and find the latest lastUpdated for Namaz
      final timestamp = data['lastUpdated'] as Timestamp?;
      if (timestamp != null) {
        final docUpdateTime = timestamp.toDate();
        if (latestNamazUpdate == null || docUpdateTime.isAfter(latestNamazUpdate)) {
          latestNamazUpdate = docUpdateTime;
        }
      }
    }
    _lastNamazUpdateTime[tabIndex] = latestNamazUpdate;


    // Ensure all prayers are present
    final List<String> expectedPrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (var prayer in expectedPrayers) {
      if (!prayerTimesMap.containsKey(prayer)) {
        prayerTimesMap[prayer] = {
          'azaanTime': 'NA', 'jammatTime': 'NA', 'awalTime': 'NA', 'akhirTime': 'NA',
        };
      }
    }

    _prayerTimes[tabIndex] = prayerTimesMap;
  }

  void _processEidTimes(int tabIndex, QuerySnapshot snapshot) {
    final Map<String, Map<String, String>> eidTimes = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docId = doc.id;

      if (docId == 'eidUlFitr') {
        eidTimes['Eid'] = {
          'jammat1': data['jammat1']?.toString() ?? 'NA',
          'jammat2': data['jammat2']?.toString() ?? 'NA',
        };
      }
      // No specific 'lastUpdated' for Eid usually, but if it exists, add logic similar to Namaz
    }

    if (!eidTimes.containsKey('Eid')) {
      eidTimes['Eid'] = {'jammat1': 'NA', 'jammat2': 'NA'};
    }
    _eidTimes[tabIndex] = eidTimes;
  }

  void _processJumuahTimes(int tabIndex, QuerySnapshot snapshot) {
    final Map<String, Map<String, String>> jumuahTimes = {};
    DateTime? latestJumuahUpdate;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docId = doc.id;

      final jumuahName = docId == 'jumajammat1' ? 'Jumuah 1' : 'Jumuah 2';

      jumuahTimes[jumuahName] = {
        'azanTime': data['azanTime']?.toString() ?? 'NA',
        'khutbaTime': data['khutbaTime']?.toString() ?? 'NA',
        'jammatTime': data['jammatTime']?.toString() ?? 'NA',
      };

      // Extract and find the latest lastUpdated for Jumuah
      final timestamp = data['lastUpdated'] as Timestamp?;
      if (timestamp != null) {
        final docUpdateTime = timestamp.toDate();
        if (latestJumuahUpdate == null || docUpdateTime.isAfter(latestJumuahUpdate)) {
          latestJumuahUpdate = docUpdateTime;
        }
      }
    }
    _lastJumuahUpdateTime[tabIndex] = latestJumuahUpdate;


    // Set defaults if not present
    if (!jumuahTimes.containsKey('Jumuah 1')) {
      jumuahTimes['Jumuah 1'] = {'azanTime': 'NA', 'khutbaTime': 'NA', 'jammatTime': 'NA'};
    }
    if (!jumuahTimes.containsKey('Jumuah 2')) {
      jumuahTimes['Jumuah 2'] = {'azanTime': 'NA', 'khutbaTime': 'NA', 'jammatTime': 'NA'};
    }

    _jumuahTimes[tabIndex] = jumuahTimes;
  }

  void _processSpecialTimes(int tabIndex, QuerySnapshot snapshot) {
    // Initialize with defaults for the new structure
    _ramadanTimes[tabIndex] = {'sehrTime': 'NA', 'iftarTime': 'NA'};
    _sunsetTimes[tabIndex] = {'tuluTime': 'NA', 'zawalTime': 'NA', 'gurubTime': 'NA'};
    _prohibitedTimes[tabIndex] = {
      'time1From': 'NA', 'time1To': 'NA',
      'time2From': 'NA', 'time2To': 'NA',
      'time3From': 'NA', 'time3To': 'NA',
      'time4From': 'NA', 'time4To': 'NA',
    };
    DateTime? latestRamadanUpdate;


    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final docId = doc.id;

      switch (docId) {
        case 'ramzan':
          _ramadanTimes[tabIndex] = {
            'sehrTime': data['sehrTime']?.toString() ?? 'NA',
            'iftarTime': data['iftarTime']?.toString() ?? 'NA',
          };
          // Extract lastUpdated for Ramadan
          final timestamp = data['lastUpdated'] as Timestamp?;
          if (timestamp != null) {
            latestRamadanUpdate = timestamp.toDate();
          }
          break;
        case 'sunset':
          _sunsetTimes[tabIndex] = {
            'tuluTime': data['tuluTime']?.toString() ?? 'NA',
            'zawalTime': data['zawalTime']?.toString() ?? 'NA',
            'gurubTime': data['gurubTime']?.toString() ?? 'NA',
          };
          break;
        case 'prohibitedTime':
          _prohibitedTimes[tabIndex] = {
            'time1From': data['time1From']?.toString() ?? 'NA',
            'time1To': data['time1To']?.toString() ?? 'NA',
            'time2From': data['time2From']?.toString() ?? 'NA',
            'time2To': data['time2To']?.toString() ?? 'NA',
            'time3From': data['time3From']?.toString() ?? 'NA',
            'time3To': data['time3To']?.toString() ?? 'NA',
            'time4From': data['time4From']?.toString() ?? 'NA',
            'time4To': data['time4To']?.toString() ?? 'NA',
          };
          break;
        case 'specialNamaz':
          _specialNamazTimes[tabIndex] = {
            'namaz1Name': data['namaz1Name']?.toString() ?? 'NA',
            'namaz1Time': data['namaz1Time']?.toString() ?? 'NA',
            'namaz2Name': data['namaz2Name']?.toString() ?? 'NA',
            'namaz2Time': data['namaz2Time']?.toString() ?? 'NA',
            'namaz3Name': data['namaz3Name']?.toString() ?? 'NA',
            'namaz3Time': data['namaz3Time']?.toString() ?? 'NA',
            'lastUpdated': data['lastUpdated']?.toString() ?? 'NA',
            'imamId': data['imamId']?.toString() ?? 'NA',
          };
          break;
      }
    }
    _lastRamadanUpdateTime[tabIndex] = latestRamadanUpdate;
  }

  void _processHadiyaDetails(int tabIndex, QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      final List<Map<String, dynamic>> hadiyaList = [];

      for (var doc in snapshot.docs) {
        final hadiyaData = doc.data() as Map<String, dynamic>;
        hadiyaData['id'] = doc.id;
        hadiyaList.add(hadiyaData);
      }

      _hadiyaDetails[tabIndex] = hadiyaList;
    } else {
      _hadiyaDetails[tabIndex] = [];
    }
  }

  void _processBayanData(int tabIndex, QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      final List<Map<String, dynamic>> bayanList = [];

      for (var doc in snapshot.docs) {
        final bayanData = doc.data() as Map<String, dynamic>;
        bayanData['id'] = doc.id;
        bayanList.add(bayanData);
      }

      _bayanData[tabIndex] = bayanList;
    } else {
      _bayanData[tabIndex] = [];
    }
  }

  // NEW: Helper to find the absolute latest update time across all sections
  void _calculateGeneralLastUpdate(int tabIndex) {
    DateTime? latest = _lastNamazUpdateTime[tabIndex];

    if (_lastJumuahUpdateTime[tabIndex] != null && (latest == null || _lastJumuahUpdateTime[tabIndex]!.isAfter(latest))) {
      latest = _lastJumuahUpdateTime[tabIndex];
    }
    if (_lastRamadanUpdateTime[tabIndex] != null && (latest == null || _lastRamadanUpdateTime[tabIndex]!.isAfter(latest))) {
      latest = _lastRamadanUpdateTime[tabIndex];
    }
    // You can add other sections like Eid, Sunset, ProhibitedTime here if they have 'lastUpdated' fields
    // and you want them to contribute to the general last update time.

    _lastGeneralUpdateTime[tabIndex] = latest;
  }

  void _clearData(int tabIndex) {
    _mosqueData.remove(tabIndex);
    _prayerTimes.remove(tabIndex);
    _eidTimes.remove(tabIndex);
    _hadiyaDetails.remove(tabIndex);
    _jumuahTimes.remove(tabIndex);
    _ramadanTimes.remove(tabIndex);
    _sunsetTimes.remove(tabIndex);
    _prohibitedTimes.remove(tabIndex);
    _bayanData.remove(tabIndex);
    _specialNamazTimes.remove(tabIndex); // Add this line

    // NEW: Clear last update times
    _lastNamazUpdateTime.remove(tabIndex);
    _lastJumuahUpdateTime.remove(tabIndex);
    _lastRamadanUpdateTime.remove(tabIndex);
    _lastGeneralUpdateTime.remove(tabIndex);
  }
  void clearMosqueData(int tabIndex) {
    _cancelSubscriptions(tabIndex);
    _clearData(tabIndex);
    _isLoading.remove(tabIndex);
    _errors.remove(tabIndex);
    notifyListeners();
  }

  @override
  void dispose() {
    for (var subscriptions in _subscriptions.values) {
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
    }
    _subscriptions.clear();
    super.dispose();
  }
}