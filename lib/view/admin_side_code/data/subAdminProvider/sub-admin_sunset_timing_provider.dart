import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rafahiyatourism/const/error_handler.dart';

class SSunsetTimingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, Stream<Map<String, String>>> _sunsetStreams = {};
  final Map<String, Map<String, String>> _sunsetCache = {};

  Stream<Map<String, String>> getSunsetTimingsStream(String userId) {
    if (_sunsetStreams.containsKey(userId)) {
      return _sunsetStreams[userId]!;
    }

    final stream = _firestore
        .collection('mosques')
        .doc(userId)
        .collection('specialTimings')
        .doc('sunset')
        .snapshots()
        .asyncMap<Map<String, String>>((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() ?? {};
        return {
          'tuluTime': (data['tuluTime'] as String?)?.trim() ?? 'Not Set',
          'gurubTime': (data['gurubTime'] as String?)?.trim() ?? 'Not Set',
          'zawalTime': (data['zawalTime'] as String?)?.trim() ?? 'Not Set',
        };
      }
      return {'tuluTime': 'Not Set', 'gurubTime': 'Not Set', 'zawalTime': 'Not Set'};
    })
        .handleError((error) {
      debugPrint('Sunset timings stream error: $error');
      return _sunsetCache[userId] ?? {'tuluTime': 'Not Set', 'gurubTime': 'Not Set', 'zawalTime': 'Not Set'};
    })
        .asBroadcastStream();

    // Cache the initial data
    stream.first.then((data) {
      _sunsetCache[userId] = data;
    });

    _sunsetStreams[userId] = stream;
    return stream;
  }

  Map<String, String>? getCachedSunsetTimings(String userId) {
    return _sunsetCache[userId];
  }

  void disposeSunsetStream(String userId) {
    _sunsetStreams.remove(userId);
    _sunsetCache.remove(userId);
  }
}
