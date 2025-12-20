
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rafahiyatourism/view/super_admin_code/models/sub_admin_model/sub_admin_model.dart';

import '../../../admin_side_code/data/models/hadiya_model.dart';

class SubAdminDetailProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Admin> _admins = [];
  final Map<String, List<HadiyaModel>> _allHadiyaDetails = {};
  final Map<String, bool> _hadiyaLoading = {};
  final Map<String, String?> _hadiyaErrors = {};
  bool _isLoading = true;
  String? _error;
  final Map<String, StreamSubscription?> _hadiyaSubscriptions = {};

  List<Admin> get admins => _admins;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all hadiya details for an admin
  List<HadiyaModel> getAllHadiyaDetails(String adminId) => _allHadiyaDetails[adminId] ?? [];

// Get specific hadiya type
  HadiyaModel? getHadiyaByType(String adminId, String type) {
    final hadiyas = _allHadiyaDetails[adminId];
    if (hadiyas == null) return null;

    try {
      return hadiyas.firstWhere((h) => h.type == type);
    } catch (e) {
      return null;
    }
  }
  bool isHadiyaLoading(String adminId) => _hadiyaLoading[adminId] ?? false;
  String? getHadiyaError(String adminId) => _hadiyaErrors[adminId];

  Future<void> loadAdmins() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      _admins = snapshot.docs.map((doc) => Admin.fromFirestore(doc)).toList();
      _error = null;
    } catch (e) {
      _error = 'Failed to load admins: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllHadiyaDetails(String adminId) async {
    try {
      _hadiyaLoading[adminId] = true;
      _hadiyaErrors[adminId] = null;
      notifyListeners();

      // Cancel any existing subscriptions
      _hadiyaSubscriptions['${adminId}_masjid']?.cancel();
      _hadiyaSubscriptions['${adminId}_maulana']?.cancel();

      // Load both Masjid and Maulana hadiyas
      final List<HadiyaModel> allHadiyas = [];

      // Load Masjid Hadiya
      final masjidHadiya = await _loadHadiyaByType(adminId, 'Masjid');
      if (masjidHadiya != null) {
        allHadiyas.add(masjidHadiya);
      }

      // Load Maulana Hadiya
      final maulanaHadiya = await _loadHadiyaByType(adminId, 'Maulana');
      if (maulanaHadiya != null) {
        allHadiyas.add(maulanaHadiya);
      }

      _allHadiyaDetails[adminId] = allHadiyas;
      _hadiyaLoading[adminId] = false;
      notifyListeners();

      // Set up real-time listeners for both types
      _setupRealTimeListeners(adminId);

    } catch (e) {
      _hadiyaErrors[adminId] = 'Failed to load hadiya details: ${e.toString()}';
      debugPrint(_hadiyaErrors[adminId]);
      _allHadiyaDetails[adminId] = [];
      _hadiyaLoading[adminId] = false;
      notifyListeners();
    }
  }

  Future<HadiyaModel?> _loadHadiyaByType(String adminId, String type) async {
    try {
      // Try main collection first
      final snapshot = await _firestore
          .collection('mosques')
          .doc(adminId)
          .collection('hadiyaDetails')
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      HadiyaModel? hadiyaDetail;

      if (snapshot.docs.isNotEmpty) {
        hadiyaDetail = HadiyaModel.fromDocument(snapshot.docs.first);

        // Enrich with subAdmin data
        final subAdminDoc = await _firestore.collection('subAdmin').doc(adminId).get();
        if (subAdminDoc.exists) {
          final subAdminData = subAdminDoc.data() as Map<String, dynamic>;
          hadiyaDetail = hadiyaDetail.withSubAdminData(subAdminData);
        }
      } else {
        // Fallback to collectionGroup search
        final directSnapshot = await _firestore
            .collectionGroup('hadiyaDetails')
            .where('subAdminId', isEqualTo: adminId)
            .where('type', isEqualTo: type)
            .limit(1)
            .get();

        if (directSnapshot.docs.isNotEmpty) {
          hadiyaDetail = HadiyaModel.fromDocument(directSnapshot.docs.first);

          final subAdminDoc = await _firestore.collection('subAdmin').doc(adminId).get();
          if (subAdminDoc.exists) {
            final subAdminData = subAdminDoc.data() as Map<String, dynamic>;
            hadiyaDetail = hadiyaDetail.withSubAdminData(subAdminData);
          }
        }
      }

      return hadiyaDetail;
    } catch (e) {
      debugPrint('Error loading $type hadiya for $adminId: $e');
      return null;
    }
  }

  void _setupRealTimeListeners(String adminId) {
    // Listen for Masjid hadiya updates
    final masjidStream = _firestore
        .collection('mosques')
        .doc(adminId)
        .collection('hadiyaDetails')
        .where('type', isEqualTo: 'Masjid')
        .limit(1)
        .snapshots();

    _hadiyaSubscriptions['${adminId}_masjid'] = masjidStream.listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var updatedHadiya = HadiyaModel.fromDocument(snapshot.docs.first);

        // Enrich with subAdmin data
        final subAdminDoc = await _firestore.collection('subAdmin').doc(adminId).get();
        if (subAdminDoc.exists) {
          final subAdminData = subAdminDoc.data() as Map<String, dynamic>;
          updatedHadiya = updatedHadiya.withSubAdminData(subAdminData);
        }

        _updateHadiyaInList(adminId, updatedHadiya);
      } else {
        // Remove Masjid hadiya if document was deleted
        _removeHadiyaFromList(adminId, 'Masjid');
      }
    }, onError: (error) {
      debugPrint('Masjid real-time listener error: $error');
    });

    // Listen for Maulana hadiya updates
    final maulanaStream = _firestore
        .collection('mosques')
        .doc(adminId)
        .collection('hadiyaDetails')
        .where('type', isEqualTo: 'Maulana')
        .limit(1)
        .snapshots();

    _hadiyaSubscriptions['${adminId}_maulana'] = maulanaStream.listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var updatedHadiya = HadiyaModel.fromDocument(snapshot.docs.first);

        // Enrich with subAdmin data
        final subAdminDoc = await _firestore.collection('subAdmin').doc(adminId).get();
        if (subAdminDoc.exists) {
          final subAdminData = subAdminDoc.data() as Map<String, dynamic>;
          updatedHadiya = updatedHadiya.withSubAdminData(subAdminData);
        }

        _updateHadiyaInList(adminId, updatedHadiya);
      } else {
        // Remove Maulana hadiya if document was deleted
        _removeHadiyaFromList(adminId, 'Maulana');
      }
    }, onError: (error) {
      debugPrint('Maulana real-time listener error: $error');
    });
  }

  void _updateHadiyaInList(String adminId, HadiyaModel updatedHadiya) {
    final currentHadiyas = _allHadiyaDetails[adminId] ?? [];
    final index = currentHadiyas.indexWhere((h) => h.type == updatedHadiya.type);

    if (index != -1) {
      currentHadiyas[index] = updatedHadiya;
    } else {
      currentHadiyas.add(updatedHadiya);
    }

    _allHadiyaDetails[adminId] = currentHadiyas;
    notifyListeners();
  }

  void _removeHadiyaFromList(String adminId, String type) {
    final currentHadiyas = _allHadiyaDetails[adminId] ?? [];
    currentHadiyas.removeWhere((h) => h.type == type);
    _allHadiyaDetails[adminId] = currentHadiyas;
    notifyListeners();
  }

  // Backward compatibility method
  Future<void> loadHadiyaDetail(String adminId) async {
    await loadAllHadiyaDetails(adminId);
  }

  // Backward compatibility getter
  HadiyaModel? getHadiyaDetail(String adminId) {
    final hadiyas = _allHadiyaDetails[adminId];
    return hadiyas != null && hadiyas.isNotEmpty ? hadiyas.first : null;
  }

  Future<void> deleteAdmin(String adminId) async {
    try {
      await _firestore.collection('subAdmin').doc(adminId).delete();
      _admins.removeWhere((admin) => admin.id == adminId);
      _allHadiyaDetails.remove(adminId);

      // Cancel subscriptions
      _hadiyaSubscriptions['${adminId}_masjid']?.cancel();
      _hadiyaSubscriptions['${adminId}_maulana']?.cancel();
      _hadiyaSubscriptions.remove('${adminId}_masjid');
      _hadiyaSubscriptions.remove('${adminId}_maulana');

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting admin: $e');
      rethrow;
    }
  }

  Future<void> toggleAdminStatus(String adminId, bool newStatus) async {
    try {
      await _firestore
          .collection('subAdmin')
          .doc(adminId)
          .update({'successfullyRegistered': newStatus});

      final index = _admins.indexWhere((admin) => admin.id == adminId);
      if (index != -1) {
        _admins[index] = _admins[index].copyWith(isActive: newStatus);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating admin status: $e');
      rethrow;
    }
  }

  Future<void> updateHadiyaStatus(String documentId, String mosqueId, bool isApproved) async {
    try {
      if (isApproved) {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('hadiyaDetails')
            .doc(documentId)
            .update({'allowed': true});
      } else {
        await _firestore
            .collection('mosques')
            .doc(mosqueId)
            .collection('hadiyaDetails')
            .doc(documentId)
            .delete();
      }

      notifyListeners();
    } catch (e) {
      throw Exception("Failed to update Hadiya status: $e");
    }
  }

  Future<void> toggleHadiyaStatus(String adminId, String hadiyaId, bool newStatus) async {
    try {
      // Update in main collection
      await _firestore
          .collection('mosques')
          .doc(adminId)
          .collection('hadiyaDetails')
          .doc(hadiyaId)
          .update({'allowed': newStatus});

      // Update in collectionGroup if exists
      final hadiyaQuery = await _firestore
          .collectionGroup('hadiyaDetails')
          .where('subAdminId', isEqualTo: adminId)
          .where(FieldPath.documentId, isEqualTo: hadiyaId)
          .get();

      for (var doc in hadiyaQuery.docs) {
        await doc.reference.update({'allowed': newStatus});
      }

      // Reload hadiya details to reflect changes
      await loadAllHadiyaDetails(adminId);
    } catch (e) {
      debugPrint('Error updating hadiya status: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllBayansForSuperAdmin() async {
    try {
      _isLoading = true;
      notifyListeners();

      final subAdminSnapshot = await _firestore
          .collection('subAdmin')
          .where('successfullyRegistered', isEqualTo: true)
          .get();

      print("SubAdmin Snapshot: ${subAdminSnapshot.docs.length}");

      final List<Map<String, dynamic>> allBayans = [];

      // For each subadmin, fetch their bayans from their mosque collection
      for (final subAdminDoc in subAdminSnapshot.docs) {
        final subAdminId = subAdminDoc.id;

        final subAdminData = subAdminDoc.data();
        print('SubAdmin Data: ${subAdminData.keys.toList()}');

        final mosqueName = _getFieldValue(subAdminData, ['masjidName', 'mosque', 'name']) ?? 'Unknown Mosque';
        final authorEmail = _getFieldValue(subAdminData, ['email', 'userEmail']) ?? 'Unknown';
        final authorName = _getFieldValue(subAdminData, ['imamName', 'fullName', 'username']) ?? 'Unknown';

        print('Processing: Mosque: $mosqueName, Author: $authorName, Email: $authorEmail');

        try {
          final bayansSnapshot = await _firestore
              .collection('mosques')
              .doc(subAdminId)
              .collection('bayan')
              .orderBy("createdAt", descending: true)
              .get();

          print('Found ${bayansSnapshot.docs.length} bayans for $mosqueName');

          for (final bayanDoc in bayansSnapshot.docs) {
            final bayanData = bayanDoc.data();
            allBayans.add({
              'id': bayanDoc.id,
              'subAdminId': subAdminId,
              'mosqueName': mosqueName,
              'title': _getFieldValue(bayanData, ['title']) ?? 'No Title',
              'videoLink': _getFieldValue(bayanData, ['videoLink']) ?? '',
              'imageUrl': _getFieldValue(bayanData, ['imageUrl']) ?? '',
              'createdAt': bayanData['createdAt'] ?? Timestamp.now(),
              'authorEmail': authorEmail,
              'authorName': authorName,
            });
          }
        } catch (e) {
          debugPrint("Error fetching bayans for $mosqueName ($subAdminId): $e");
          continue;
        }
      }

      // Sort by creation date, newest first
      allBayans.sort((a, b) => (b['createdAt'] as Timestamp).compareTo(a['createdAt'] as Timestamp));

      print("✅ Total bayans fetched: ${allBayans.length}");
      return allBayans;
    } catch (e) {
      debugPrint("❌ Error fetching all bayans: $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _getFieldValue(Map<String, dynamic> data, List<String> possibleKeys) {
    for (final key in possibleKeys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  Future<void> deleteBayanAsSuperAdmin(String subAdminId, String bayanId) async {
    try {
      await _firestore
          .collection('mosques')
          .doc(subAdminId)
          .collection('bayan')
          .doc(bayanId)
          .delete();

      debugPrint("✅ Bayan deleted by superadmin successfully");
    } catch (e) {
      debugPrint("❌ Error deleting bayan as superadmin: $e");
      throw e;
    }
  }

  void clearHadiyaCache(String adminId) {
    _allHadiyaDetails.remove(adminId);
    _hadiyaLoading.remove(adminId);
    _hadiyaErrors.remove(adminId);

    // Cancel subscriptions
    _hadiyaSubscriptions['${adminId}_masjid']?.cancel();
    _hadiyaSubscriptions['${adminId}_maulana']?.cancel();
    _hadiyaSubscriptions.remove('${adminId}_masjid');
    _hadiyaSubscriptions.remove('${adminId}_maulana');
  }

  @override
  void dispose() {
    // Cancel all subscriptions when provider is disposed
    for (var subscription in _hadiyaSubscriptions.values) {
      subscription?.cancel();
    }
    _hadiyaSubscriptions.clear();
    super.dispose();
  }
}