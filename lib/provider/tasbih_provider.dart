import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../view/admin_side_code/data/models/dikhr_model.dart';

class TasbihProvider extends ChangeNotifier {
  static const int LOOP_SIZE = 33;

  int _counter = 0;
  int _maxCount = 33;
  int _loop = 1;
  bool _isMuted = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, Map<String, dynamic>> _userStats = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Map<String, Map<String, dynamic>> get userStats => _userStats;

  int _lastSessionCount = 0;
  int _lastSessionLoops = 0;
  Dikhr _lastSessionDikhr = defaultDikhrs.first;

  int get counter => _counter;
  int get maxCount => _maxCount;
  int get loop => _loop;
  bool get isMuted => _isMuted;

  int get lastSessionCount => _lastSessionCount;
  int get lastSessionLoops => _lastSessionLoops;
  Dikhr get lastSessionDikhr => _lastSessionDikhr;

  List<Dikhr> _customDikhrs = [];
  List<Dikhr> get allDikhrs => [...defaultDikhrs, ..._customDikhrs];

  Dikhr _selectedDikhr = defaultDikhrs.first;
  Dikhr get selectedDikhr => _selectedDikhr;

  Future<void> incrementCounter(BuildContext context) async {
    _counter++;

    // Update loop count
    if (_counter % LOOP_SIZE == 0) {
      _loop = (_counter ~/ LOOP_SIZE) + 1;
    }

    // ✅ Always save progress (no duplicates)
    _saveSessionToFirebase();

    // Check if custom target reached
    if (_counter >= _maxCount) {
      _showCompletionDialog(context);
    }

    saveIncrementalProgress();
    notifyListeners();
  }

  Future<void> saveIncrementalProgress() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final progressData = {
          'dikhr_name': _selectedDikhr.name,
          'current_count': _counter,
          'current_loop': _loop,
          'custom_target': _maxCount,
          'last_updated': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(user.uid).update({
          'current_session': progressData,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving incremental progress: $e');
      }
    }
  }

  /// ✅ Fixed: save exact counter & overwrite same doc (no duplicates)
  Future<void> _saveSessionToFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        int completedLoops = _counter ~/ LOOP_SIZE;

        final sessionData = {
          'dikhr_name': _selectedDikhr.name,
          'dikhr_arabic': _selectedDikhr.arabic,
          'count': _counter,
          'loops': completedLoops,
          'timestamp': FieldValue.serverTimestamp(),
          'total_count': _counter,
          'custom_target': _maxCount,
        };

        // ✅ One document per Dikhr session
        String docId = '${_selectedDikhr.name}_session';

        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('sessions')
            .doc(docId)
            .set(sessionData, SetOptions(merge: true));

        await _updateUserStats(sessionData);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving to Firebase: $e');
      }
    }
  }

  Future<void> _updateUserStats(Map<String, dynamic> sessionData) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final dikhrName = sessionData['dikhr_name'];
        final totalCount = sessionData['total_count'];

        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        final currentStats = userDoc.data()?['stats'] ?? {};

        final dikhrStats = currentStats[dikhrName] ?? {
          'total_count': 0,
          'sessions': 0,
          'last_practiced': null,
        };

        dikhrStats['total_count'] =
            (dikhrStats['total_count'] ?? 0) + totalCount;
        dikhrStats['sessions'] = (dikhrStats['sessions'] ?? 0) + 1;
        dikhrStats['last_practiced'] = FieldValue.serverTimestamp();

        currentStats[dikhrName] = dikhrStats;

        await _firestore.collection('users').doc(user.uid).update({
          'stats': currentStats,
        });

        _userStats = Map<String, Map<String, dynamic>>.from(currentStats);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user stats: $e');
      }
    }
  }

  Future<void> loadCurrentSession() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final sessionData = userDoc.data()?['current_session'];
          if (sessionData != null) {
            if (sessionData['dikhr_name'] == _selectedDikhr.name) {
              _counter = sessionData['current_count'] ?? 0;
              _loop = sessionData['current_loop'] ?? 1;
              _maxCount = sessionData['custom_target'] ?? LOOP_SIZE;
              notifyListeners();
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading current session: $e');
      }
    }
  }

  Future<void> loadUserStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          _userStats = Map<String, Map<String, dynamic>>.from(
              userDoc.data()?['stats'] ?? {});
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading user stats: $e');
      }
    }
  }

  Future<void> loadSessionFromHistory(Map<String, dynamic> sessionData) async {
    // Add null checks
    final dikhrName = sessionData['dikhr_name'] ?? 'Subhan Allah';
    final dikhrArabic = sessionData['dikhr_arabic'] ?? dikhrName;
    final totalCount = sessionData['total_count'] ?? sessionData['count'] ?? 0;
    final customTarget = sessionData['custom_target'] ?? TasbihProvider.LOOP_SIZE;

    Dikhr targetDikhr = allDikhrs.firstWhere(
          (dikhr) => dikhr.name == dikhrName,
      orElse: () => Dikhr(
        name: dikhrName,
        arabic: dikhrArabic,
      ),
    );

    _selectedDikhr = targetDikhr;
    _counter = totalCount;
    _loop = (_counter ~/ LOOP_SIZE) + 1;
    _maxCount = customTarget;

    notifyListeners();
    saveIncrementalProgress();
  }

  void initialize() {
    loadUserStats();
    loadCurrentSession();
  }

  void _showCompletionDialog(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Counter Complete"),
          content: Text("You completed $_maxCount ${_selectedDikhr.name}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    });
  }

  void resetCounter() {
    if (_counter > 0) {
      int completedLoops = _counter ~/ LOOP_SIZE;
      if (completedLoops > 0) {
        _lastSessionCount = _counter;
        _lastSessionLoops = completedLoops;
        _lastSessionDikhr = _selectedDikhr;
        _saveSessionToFirebase();
      }
    }

    _counter = 0;
    _loop = 1;
    _maxCount = LOOP_SIZE;

    _clearCurrentSession();
    notifyListeners();
  }

  Future<void> _clearCurrentSession() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'current_session': FieldValue.delete(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing current session: $e');
      }
    }
  }

  void setMaxCount(int count) {
    _maxCount = count;
    notifyListeners();
  }

  void setSelectedDikhr(Dikhr dikhr) {
    if (_selectedDikhr != dikhr) {
      if (_counter > 0) {
        int completedLoops = _counter ~/ LOOP_SIZE;
        if (completedLoops > 0) {
          _lastSessionCount = _counter;
          _lastSessionLoops = completedLoops;
          _lastSessionDikhr = _selectedDikhr;
          _saveSessionToFirebase();
        }
      }

      _selectedDikhr = dikhr;
      _counter = 0;
      _loop = 1;
      notifyListeners();
    }
  }

  void addCustomDikhr(Dikhr dikhr) {
    _customDikhrs.add(dikhr);
    _selectedDikhr = dikhr;
    notifyListeners();
  }

  void removeCustomDikhr(Dikhr dikhr) {
    _customDikhrs.remove(dikhr);
    if (_selectedDikhr == dikhr) {
      _selectedDikhr = defaultDikhrs.first;
    }
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }
}
