import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rafahiyatourism/const/error_handler.dart';
import '../models/eid_timings_model.dart';
import '../models/prohibited_time_model.dart';
import '../models/salah_timing_model.dart';
import 'dart:async';

import '../models/special_namaz.dart';


class SubAdminTimingsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _sunsetExists = false;
  bool get sunsetExists => _sunsetExists;
  bool _ramzanExists = false;
  bool get ramzanExists => _ramzanExists;

  bool _isLoading = false;
  bool get isLoading => _isLoading;



  final Map<String, Stream<Map<String, String>>> _sunsetStreams = {};
  final Map<String, Map<String, String>> _sunsetCache = {};

  final Map<String, Stream<Map<String, String>>> _ramzanStreams = {};
  final Map<String, Map<String, String>> _ramzanCache = {};

  final Map<String, Stream<Map<String, String>>> _jummaStreams = {};
  final Map<String, Map<String, String>> _jummaCache = {};

  final Map<String, Stream<Map<String, Map<String, String>>>> _namazStreams = {};
  final Map<String, Map<String, Map<String, String>>> _namazCache = {};

  final Map<String, StreamSubscription?> _eidSubscriptions = {};

  final Map<String, bool> _eidSaved = {};
  bool isEidSaved(String docId) => _eidSaved[docId] ?? false;




  final Map<String, bool> _loadingStates = {};
  final Map<String, bool> _savedStates = {};
  final Map<String, StreamSubscription?> _subscriptions = {};
  final Map<String, bool> _jummaExists = {};
  final Map<String, StreamSubscription?> _jummaSubscriptions = {};

  StreamSubscription? _sunsetSub;
  StreamSubscription<DocumentSnapshot>? _ramzanSubscription;

  final Map<String, bool> _savedDocs = {};
  final Map<String, bool> _savedSpecial = {};
  StreamSubscription<DocumentSnapshot>? _prohibitedSub;

  bool isProhibitedTimeSave(String docId) => _savedDocs[docId] ?? false;
  bool isSpecialTimeSave(String docId) => _savedSpecial[docId] ?? false;




  bool jummaExists(String namazName) => _jummaExists[namazName] ?? false;
  bool isLoadingNamaz(String namazName) => _loadingStates[namazName] ?? false;
  bool isNamazSaved(String namazName) => _savedStates[namazName] ?? false;

  /// Listen in real-time to a namaz timing
  void listenToNamazTiming(String imamId, String namazName) {
    _subscriptions[namazName]?.cancel();
    _subscriptions[namazName] = _firestore
        .collection('mosques')
        .doc(imamId)
        .collection('namazTimings')
        .doc(namazName.toLowerCase())
        .snapshots()
        .listen((doc) {
      _savedStates[namazName] = doc.exists;
      notifyListeners();
    });
  }


  void listenToJummaTiming(String namazName, String imamId) {
    _jummaSubscriptions[namazName]?.cancel();

    _jummaSubscriptions[namazName] = _firestore
        .collection('mosques')
        .doc(imamId)
        .collection('namazTimings')
        .doc(namazName.toLowerCase())
        .snapshots()
        .listen((doc) {
      _jummaExists[namazName] = doc.exists;
      notifyListeners();
    });
  }

  Future<void> addNamazTiming({
    required String namazName,
    required String azaanTime,
    required String jammatTime,
    String? awwalTime,
    String? akhirTime,
    required String imamId,
  }) async {
    _loadingStates[namazName] = true;
    notifyListeners();

    try {
      await _firestore
          .collection('mosques')
          .doc(imamId)
          .collection('namazTimings')
          .doc(namazName.toLowerCase())
          .set({
        'namazName': namazName,
        'azaanTime': azaanTime,
        'jammatTime': jammatTime,
        'awwalTime': awwalTime ?? '',
        'akhirTime': akhirTime ?? '',
        'imamId': imamId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } finally {
      _loadingStates[namazName] = false;
      notifyListeners();
    }
  }


  // // TODO ADD METHODS
  // Future<void> addNamazTiming({
  //   required String namazName,
  //   required String azaanTime,
  //   required String jammatTime,
  //   String? awwalTime,
  //   String? akhirTime,
  //   required String imamId,
  // }) async {
  //   _loadingStates[namazName] = true;
  //   notifyListeners();
  //
  //   try {
  //     await _firestore
  //         .collection('mosques')
  //         .doc(imamId)
  //         .collection('namazTimings')
  //         .doc(namazName.toLowerCase())
  //         .set({
  //       'namazName': namazName,
  //       'azaanTime': azaanTime,
  //       'jammatTime': jammatTime,
  //       'awwalTime': awwalTime ?? '',
  //       'akhirTime': akhirTime ?? '',
  //       "imamId": imamId,
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     ErrorHandler.showError(e);
  //     rethrow;
  //   } finally {
  //     _loadingStates[namazName] = false;
  //     notifyListeners();
  //   }
  // }



  Future<void> saveNamazTiming({
    required String namazName,
    required String azaanTime,
    required String jammatTime,
    String? awwalTime,
    String? akhirTime,
    required String imamId,
  }) async {
    // Mark as loading for this salah

    _loadingStates[namazName] = true;
    notifyListeners();

    try {
      await _firestore
          .collection('mosques')
          .doc(imamId)
          .collection('namazTimings')
          .doc(namazName.toLowerCase())
          .set({
        'namazName': namazName,
        'azaanTime': azaanTime,
        'jammatTime': jammatTime,
        'awwalTime': awwalTime ?? '',
        'akhirTime': akhirTime ?? '',
        'imamId': imamId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));


    } catch (e) {
      print("ErrorGetting$e");
      ErrorHandler.showError(e);
      rethrow;
    } finally {
      // Reset loading state
      _loadingStates[namazName] = false;
      notifyListeners();
    }
  }


  //
  // // TODO ADD JUMMA NAMAZ TIME
  // Future<void> addJummaNamazTime({
  //   required String namazName,
  //   required String azanTime,
  //   String? khutbaTime,
  //   required String jammatTime,
  //   required String imamId,
  // }) async {
  //   _loadingStates[jammatTime] = true;
  //   notifyListeners();
  //
  //   print("BBBBB ${azanTime}, ${namazName}, ${khutbaTime}, ${jammatTime}");
  //
  //   try {
  //     await _firestore
  //         .collection('mosques')
  //         .doc(imamId)
  //         .collection('namazTimings')
  //         .doc(namazName.toLowerCase())
  //         .set({
  //       'namazName': namazName,
  //       'azanTime': azanTime,
  //       'khutbaTime': khutbaTime,
  //       'jammatTime': jammatTime,
  //       "imamId": imamId,
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     });
  //   } catch (e) {
  //     ErrorHandler.showError(e);
  //     rethrow;
  //   } finally {
  //     _loadingStates[namazName] = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> deleteNamazTiming(String userId, String salahKey) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('namazTimings')
          .doc(salahKey.toLowerCase())
          .delete();

      // Clear cache for this salah
      if (_namazCache[userId] != null) {
        _namazCache[userId]!.remove(salahKey);
      }
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> deleteJummaTiming(String userId, String jummaKey) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('namazTimings')
          .doc(jummaKey.toLowerCase())
          .delete();

      // Clear cache for Jumma timings
      _jummaCache.remove(userId);
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  // ✅ Save Jumma timing
  Future<void> addJummaNamazTime({
    required String namazName,
    required String azanTime,
    String? khutbaTime,
    required String jammatTime,
    required String imamId,
  }) async {
    _loadingStates[namazName] = true;
    notifyListeners();

    try {
      await _firestore
          .collection('mosques')
          .doc(imamId)
          .collection('namazTimings')
          .doc(namazName.toLowerCase())
          .set({
        'namazName': namazName,
        'azanTime': azanTime,
        'khutbaTime': khutbaTime ?? '',
        'jammatTime': jammatTime,
        'imamId': imamId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    } finally {
      _loadingStates[namazName] = false;
      notifyListeners();
    }
  }


  Future<void> saveJummaNamazTime({
    required String namazName,
    required String azanTime,
    String? khutbaTime,
    required String jammatTime,
    required String imamId,
  }) async {
    _loadingStates[namazName] = true;  // FIXED
    notifyListeners();

    print("AAAAA $azanTime, $namazName, $khutbaTime, $jammatTime");

    try {
      await _firestore
          .collection('mosques')
          .doc(imamId)
          .collection('namazTimings')
          .doc(namazName.toLowerCase()) // correct doc id
          .set({
        'namazName': namazName,
        'azanTime': azanTime,
        'khutbaTime': khutbaTime,
        'jammatTime': jammatTime,
        "imamId": imamId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // merge in case only some fields change
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    } finally {
      _loadingStates[namazName] = false;  // FIXED
      notifyListeners();
    }
  }




  // ✅ Add Ramzan Timing
  Future<void> addRamzanTiming({
    required String sehrTime,
    required String iftarTime,
    required String mosqueId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('mosques')
          .doc(mosqueId)
          .collection('specialTimings')
          .doc('ramzan')
          .set({
        'sehrTime': sehrTime,
        'iftarTime': iftarTime,
        "imamId": mosqueId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void listenToRamzanTiming(String mosqueId) {
    _ramzanSubscription?.cancel();
    _ramzanSubscription = _firestore
        .collection('mosques')
        .doc(mosqueId)
        .collection('specialTimings')
        .doc('ramzan')
        .snapshots()
        .listen((doc) {
      _ramzanExists = doc.exists;
      notifyListeners();
    });
  }


  void listenToSunsetTiming(String userId) {
    _sunsetSub?.cancel(); // cleanup old
    _sunsetSub = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('sunset')
        .snapshots()
        .listen((doc) {
      _sunsetExists = doc.exists;
      notifyListeners();
    });
  }


  void listenToProhibitedTime(String userId) {
    _prohibitedSub?.cancel();
    _prohibitedSub = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('prohibitedTime')
        .snapshots()
        .listen((snapshot) {
      _savedDocs['prohibitedTime'] = snapshot.exists;
      notifyListeners();
    });
  }


  void listenEidTiming(String userId, String docId) {
    _eidSubscriptions[docId]?.cancel();
    _eidSubscriptions[docId] = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc(docId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        _eidSaved[docId] = true; // ✅ mark as saved
      } else {
        _eidSaved[docId] = false; // ✅ mark as not saved
      }
      notifyListeners();
    });
  }


  Future<void> deleteSunsetTimingField(String userId, String fieldKey) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('sunset');

      // Get current data
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        // Update the specific field to empty string
        await docRef.update({
          fieldKey: 'Not set',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Update cache
        if (_sunsetCache[userId] != null) {
          _sunsetCache[userId]![fieldKey] = 'Not set';
        }
        notifyListeners();
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> deleteAllSunsetTimings(String userId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('sunset')
          .delete();

      // Clear cache
      _sunsetCache.remove(userId);
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> addSunsetTiming({
    required String tuluTime,
    required String gurubTime,
    required String zawalTime,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('sunset')
          .set({
        'tuluTime': tuluTime,
        'gurubTime': gurubTime,
        'zawalTime': zawalTime,
        "imamId": userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add this method to your SubAdminTimingsProvider class
  Future<void> deleteRamzanTimings(String userId) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('ramzan');

      // Update both fields to 'Not set' instead of deleting the document
      await docRef.set({
        'sehrTime': 'Not set',
        'iftarTime': 'Not set',
        'imamId': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update cache
      if (_ramzanCache[userId] != null) {
        _ramzanCache[userId]!['sehrTime'] = 'Not set';
        _ramzanCache[userId]!['iftarTime'] = 'Not set';
      }
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

// Alternative: Method to delete entire Ramzan document
  Future<void> deleteRamzanDocument(String userId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('ramzan')
          .delete();

      // Clear cache
      _ramzanCache.remove(userId);
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }
// Update the existing addEidTiming method in your provider
  Future<void> addEidTiming({
    required String jammat1,
    required String jammat2,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('eidUlFitr')
          .set({
        'jammat1': jammat1.isEmpty ? 'Not set' : jammat1,
        'jammat2': jammat2.isEmpty ? 'Not set' : jammat2,
        "imamId": userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ✅ Mark as saved
      _eidSaved['eidUlFitr'] = true;
      listenEidTiming(userId, 'eidUlFitr');
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addEidUlAzha({
    required String jammat1,
    required String jammat2,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('eidUlAzha')
          .set({
        'jammat1': jammat1.isEmpty ? 'Not set' : jammat1,
        'jammat2': jammat2.isEmpty ? 'Not set' : jammat2,
        "imamId": userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> prohibitedTiming({
    required String time1From,
    required String time1To,
    required String time2From,
    required String time2To,
    required String time3From,
    required String time3To,
    required String time4From,
    required String time4To,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('prohibitedTime')
          .set({
        'time1From': time1From,
        'time1To': time1To,
        'time2From': time2From,
        'time2To': time2To,
        'time3From': time3From,
        'time3To': time3To,
        'time4From': time4From,
        'time4To': time4To,
        "imamId": userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to create if not exists

      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  // // ✅ FIXED prohibitedTiming method
  // Future<void> prohibitedTiming({
  //   required String time1,
  //   required String time2,
  //   required String userId,
  // }) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     await _firestore
  //         .collection('mosques')
  //         .doc(userId)
  //         .collection('specialTimings')
  //         .doc('prohibitedTime')
  //         .set({
  //       'time1': time1,
  //       'time2': time2,
  //       "imamId": userId,
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     });
  //     notifyListeners();
  //   } catch (e) {
  //     ErrorHandler.showError(e);
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

// ✅ FIXED streamProhibitedTiming
  Stream<ProhibitedTime> streamProhibitedTiming(String userId) {
    return FirebaseFirestore.instance
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('prohibitedTime')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return ProhibitedTime.fromMap(doc.data() ?? {});
      } else {
        // Return empty ProhibitedTime when document doesn't exist
        return ProhibitedTime(
          time1From: '', time1To: '',
          time2From: '', time2To: '',
          time3From: '', time3To: '',
          time4From: '', time4To: '',
          imamId: userId,
        );
      }
    });
  }



  // Stream for SpecialNamaz (the missing one)
  Stream<SpecialNamaz> streamSpecialNamaz(String userId) {
    return _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('specialNamaz')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return SpecialNamaz.fromMap(doc.data() ?? <String, dynamic>{});
      } else {
        // Return empty SpecialNamaz when document doesn't exist
        return SpecialNamaz(
          namaz1Name: '', namaz1Time: '',
          namaz2Name: '', namaz2Time: '',
          namaz3Name: '', namaz3Time: '',
          imamId: userId,
        );
      }
    });
  }



  Future<void> updateProhibitedTime({
    required String userId,
    required String index,
    required String from,
    required String to,
  }) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('prohibitedTime');

      // Check if document exists first
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'time${index}From': from,
          'time${index}To': to,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create the document with initial structure
        Map<String, dynamic> initialData = {
          'imamId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Initialize all time slots
        for (int i = 1; i <= 4; i++) {
          initialData['time${i}From'] = '';
          initialData['time${i}To'] = '';
        }

        // Set the specific time slot being updated
        initialData['time${index}From'] = from;
        initialData['time${index}To'] = to;

        await docRef.set(initialData);
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }


  Future<void> deleteSpecialNamaz({
    required String userId,
    required String nameField,
    required String timeField,
  }) async {
    try {
      final docRef = _firestore
          .collection("mosques")
          .doc(userId)
          .collection("specialTimings")
          .doc("specialNamaz");

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          nameField: '', // Clear the name field
          timeField: '', // Clear the time field
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create document with empty values if it doesn't exist
        Map<String, dynamic> initialData = {
          'imamId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        for (int i = 1; i <= 3; i++) {
          initialData['namaz${i}Name'] = '';
          initialData['namaz${i}Time'] = '';
        }

        await docRef.set(initialData);
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> deleteAllSpecialNamaz(String userId) async {
    try {
      await _firestore
          .collection("mosques")
          .doc(userId)
          .collection("specialTimings")
          .doc("specialNamaz")
          .delete();

      // Clear saved state
      _savedSpecial['specialNamaz'] = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }


  Future<void> deleteProhibitedTime({
    required String userId,
    required String index,
  }) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('prohibitedTime');

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'time${index}From': '',
          'time${index}To': '',
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create document with empty values if it doesn't exist
        Map<String, dynamic> initialData = {
          'imamId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        for (int i = 1; i <= 4; i++) {
          initialData['time${i}From'] = '';
          initialData['time${i}To'] = '';
        }

        await docRef.set(initialData);
      }

      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> deleteAllProhibitedTimes(String userId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('prohibitedTime')
          .delete();

      // Clear saved state
      _savedDocs['prohibitedTime'] = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }


  // Future<void> addEidUlAzha({
  //   required String jammat1,
  //   required String jammat2,
  //   required String userId,
  // }) async
  // {
  //   _isLoading = true;
  //   notifyListeners();
  //   try {
  //     await _firestore
  //         .collection('mosques')
  //         .doc(userId)
  //         .collection('specialTimings')
  //         .doc('eidUlAzha')
  //         .set({
  //       'jammat1': jammat1,
  //       'jammat2': jammat2,
  //       "imamId": userId,
  //       'lastUpdated': FieldValue.serverTimestamp(),
  //     });
  //     notifyListeners();
  //   } catch (e) {
  //     ErrorHandler.showError(e);
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }


  Future<void> specialNamazTiming({
    required String namaz1Name,
    required String namaz1Time,
    required String namaz2Name,
    required String namaz2Time,
    required String namaz3Name,
    required String namaz3Time,
    required String userId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc('specialNamaz')
          .set({
        'namaz1Name': namaz1Name,
        'namaz1Time': namaz1Time,
        'namaz2Name': namaz2Name,
        'namaz2Time': namaz2Time,
        'namaz3Name': namaz3Name,
        'namaz3Time': namaz3Time,
        "imamId": userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to create if not exists

      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // Add these methods to your SubAdminTimingsProvider class

// Delete specific Eid timing field
  Future<void> deleteEidTiming({
    required String userId,
    required String eidType,
    required String fieldKey,
  }) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc(eidType);

      // Get current data
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        // Update the specific field to 'Not set'
        await docRef.update({
          fieldKey: 'Not set',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Update cache if needed
        notifyListeners();
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

// Delete entire Eid timing document
  Future<void> deleteAllEidTimings({
    required String userId,
    required String eidType,
  }) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc(eidType)
          .delete();

      // Clear saved state
      _eidSaved[eidType] = false;
      notifyListeners();
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

// Delete both Jamaat timings for Eid
  Future<void> deleteEidTimingField({
    required String userId,
    required String eidType,
    required String fieldKey,
  }) async {
    try {
      final docRef = _firestore
          .collection('mosques')
          .doc(userId)
          .collection('specialTimings')
          .doc(eidType);

      // Get current data
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data() ?? {};

        // Update the specific field to 'Not set'
        await docRef.update({
          fieldKey: 'Not set',
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        notifyListeners();
      } else {
        await docRef.set({
          'jammat1': fieldKey == 'jammat1' ? 'Not set' : '',
          'jammat2': fieldKey == 'jammat2' ? 'Not set' : '',
          'imamId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }

  Future<void> updateSpecialNamaz({
    required String userId,
    required String nameField,
    required String timeField,
    required String newName,
    required String newTime,
  }) async {
    try {
      final docRef = _firestore
          .collection("mosques")
          .doc(userId)
          .collection("specialTimings")
          .doc("specialNamaz");

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          nameField: newName,
          timeField: newTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Create document with initial structure
        Map<String, dynamic> initialData = {
          'imamId': userId,
          'lastUpdated': FieldValue.serverTimestamp(),
        };

        // Initialize all namaz fields
        for (int i = 1; i <= 3; i++) {
          initialData['namaz${i}Name'] = '';
          initialData['namaz${i}Time'] = '';
        }

        // Set the specific fields being updated
        initialData[nameField] = newName;
        initialData[timeField] = newTime;

        await docRef.set(initialData);
      }
    } catch (e) {
      ErrorHandler.showError(e);
      rethrow;
    }
  }


  /// Listen to Firestore to enable/disable Save button
  StreamSubscription<DocumentSnapshot>? _specialNamazSub;
  void listenToSpecialNamaz(String userId) {
    _specialNamazSub?.cancel();
    _specialNamazSub = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('specialNamaz')
        .snapshots()
        .listen((snapshot) {
      _savedSpecial['specialNamaz'] = snapshot.exists;
      notifyListeners();
    });
  }




  // TODO GET METHODS
  Stream<Map<String, String>> getSunsetTimingsStream(String userId) {
    // Return existing stream if available
    if (_sunsetStreams.containsKey(userId)) {
      return _sunsetStreams[userId]!;
    }

    // Create new stream
    final stream =
    _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('sunset')
        .snapshots()
        .asyncMap<Map<String, String>>((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final timings = {
          'tuluTime': (data['tuluTime'] as String?)?.trim() ?? 'Not set',
          'gurubTime': (data['gurubTime'] as String?)?.trim() ?? 'Not set',
          'zawalTime': (data['zawalTime'] as String?)?.trim() ?? 'Not set',
        };
        _sunsetCache[userId] = timings; // Update cache
        return timings;
      }
      return {'tuluTime': 'Not set', 'gurubTime': 'Not set', 'zawalTime': 'Not set'};
    })
        .handleError((error) {
      debugPrint('Sunset timings stream error: $error');
      return _sunsetCache[userId] ?? {'tuluTime': 'Not set', 'gurubTime': 'Not set', 'zawalTime': 'Not set'};
    })
        .asBroadcastStream();

    _sunsetStreams[userId] = stream;
    return stream;
  }

  Map<String, String>? getCachedSunsetTimings(String userId) {
    return _sunsetCache[userId];
  }

  void disposeSunsetStream(String userId) {
    _sunsetStreams.remove(userId);
  }

  Stream<Map<String, String>> getRamzanTimingsStream(String userId) {
    if (_ramzanStreams.containsKey(userId)) {
      return _ramzanStreams[userId]!;
    }

    final stream =
    _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('ramzan')
        .snapshots()
        .asyncMap<Map<String, String>>((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        final timings = {
          'sehrTime': (data['sehrTime'] as String?)?.trim() ?? '',
          'iftarTime': (data['iftarTime'] as String?)?.trim() ?? '',
        };
        _ramzanCache[userId] = timings;
        return timings;
      }
      return {'sehrTime': '', 'iftarTime': ''};
    })
        .handleError((error) {
      debugPrint('Ramzan timings stream error: $error');
      return _ramzanCache[userId] ?? {'sehrTime': '', 'iftarTime': ''};
    })
        .asBroadcastStream();

    _ramzanStreams[userId] = stream;
    return stream;
  }

  Map<String, String>? getCachedRamzanTimings(String userId) {
    return _ramzanCache[userId];
  }

  void disposeRamzanStream(String userId) {
    _ramzanStreams.remove(userId);
  }

  String normalizeTime(String? time) {
    if (time == null || time.isEmpty || time == 'Not set') return 'Not set';
    return time.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Stream<Map<String, String>> getJummaTimingsStream(String userId) {
    if (_jummaStreams.containsKey(userId)) {
      return _jummaStreams[userId]!;
    }

    final stream = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('namazTimings')
        .snapshots()
        .asyncMap<Map<String, String>>((snapshot) {
      String jamaat1 = 'Not set';
      String azaan1 = 'Not set';
      String khutba1 = 'Not set';

      String jamaat2 = 'Not set';
      String azaan2 = 'Not set';
      String khutba2 = 'Not set';

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final docId = doc.id.toLowerCase().replaceAll(' ', ''); // normalized

        print("anoshka $docId");

        if (docId == 'jumajammat1') {
          jamaat1 = normalizeTime(data['jammatTime']?.toString().trim() ?? 'Not set');
          azaan1  = normalizeTime(data['azanTime']?.toString().trim() ?? 'Not set');
          khutba1 = normalizeTime(data['khutbaTime']?.toString().trim() ?? 'Not set');
        } else if (docId == 'jumajammat2') {
          jamaat2 = normalizeTime(data['jammatTime']?.toString().trim() ?? 'Not set');
          azaan2  = normalizeTime(data['azanTime']?.toString().trim() ?? 'Not set');
          khutba2 = normalizeTime(data['khutbaTime']?.toString().trim() ?? 'Not set');
        }
      }

      final timings = {
        'jamaat1': jamaat1.isEmpty ? 'Not set' : jamaat1,
        'azaan1': azaan1.isEmpty ? 'Not set' : azaan1,
        'khutba1': khutba1.isEmpty ? 'Not set' : khutba1,
        'jamaat2': jamaat2.isEmpty ? 'Not set' : jamaat2,
        'azaan2': azaan2.isEmpty ? 'Not set' : azaan2,
        'khutba2': khutba2.isEmpty ? 'Not set' : khutba2,
      };

      _jummaCache[userId] = timings;
      return timings;
    }).handleError((error) {
      debugPrint('Jumma timings stream error: $error');
      return _jummaCache[userId] ?? {
        'jamaat1': 'Not set', 'azaan1': 'Not set', 'khutba1': 'Not set',
        'jamaat2': 'Not set', 'azaan2': 'Not set', 'khutba2': 'Not set',
      };
    }).asBroadcastStream();

    _jummaStreams[userId] = stream;
    return stream;
  }

  Stream<EidTiming> streamEidTimings(String userId, String eidType) {
    return FirebaseFirestore.instance
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc(eidType)
        .snapshots()
        .map((doc) => EidTiming.fromMap(doc.data() ?? {}));
  }

  Stream<SalahTimings> streamAllSalahTimings(String userId) {
    return FirebaseFirestore.instance
        .collection('mosques')
        .doc(userId)
        .collection('namazTimings')
        .snapshots()
        .map((snapshot) => SalahTimings.fromSnapshots(snapshot.docs));
  }


  Map<String, String>? getCachedJummaTimings(String userId) {
    return _jummaCache[userId];
  }

  void disposeJummaStream(String userId) {
    _jummaStreams.remove(userId);
  }


  Stream<Map<String, Map<String, String>>> getNamazTiming(String userId) {
    if (_namazStreams.containsKey(userId)) {
      return _namazStreams[userId]!;
    }

    final stream = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('namazTimings')
        .snapshots()
        .asyncMap<Map<String, Map<String, String>>>((snapshot) {
      final Map<String, Map<String, String>> timings = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final salah = doc.id.toLowerCase().trim();

        timings[salah] = {
          'azaan': (data['azaanTime'] ?? '').toString().trim(),
          'jamaat': (data['jammatTime'] ?? '').toString().trim(),
          'awwal': (data['awwalTime'] ?? '').toString().trim(),
          'akhir': (data['akhirTime'] ?? '').toString().trim(),
        };
      }

      _namazCache[userId] = timings;
      return timings;
    }).handleError((error) {
      debugPrint('Namaz timings stream error: $error');
      return _namazCache[userId] ?? {};
    }).asBroadcastStream();

    _namazStreams[userId] = stream;
    return stream;
  }


  Map<String, Map<String, String>>? getCachedNamazTimings(String userId) {
    return _namazCache[userId];
  }

  void disposeNamazStream(String userId) {
    _namazStreams.remove(userId);
  }

  @override
  void dispose() {
    _sunsetSub?.cancel();
    _ramzanSubscription?.cancel();
    _prohibitedSub?.cancel();
    for (var sub in _eidSubscriptions.values) {
      sub?.cancel();
    }
    super.dispose();
  }
}
