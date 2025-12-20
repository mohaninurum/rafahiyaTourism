import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../utils/model/add_umrah_packages_model.dart';
import '../view/super_admin_code/models/wallet_doc_model.dart';

class WalletDocumentProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final List<Document> _documents = [];
  final Map<String, AddUmrahPackage> _packageCache = {};

  List<Document> get documents => _documents;

  bool hasUserDocument(String userId) {
    return _documents.any((doc) => doc.userId == userId);
  }

  Document? getUserDocument(String userId) {
    try {
      return _documents.firstWhere((doc) => doc.userId == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadDocumentsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_wallet')
          .where('userId', isEqualTo: userId)
          .get();

      _documents.clear();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final document = Document.fromFirestore(data, doc.id);
        _documents.add(document);

        if (document.packageId != null && document.packageId!.isNotEmpty) {
          await _fetchPackageDetails(document.packageId!);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading documents: $e');
      rethrow;
    }
  }

  Future<void> _fetchPackageDetails(String packageId) async {
    if (_packageCache.containsKey(packageId)) return;

    try {
      final doc = await _firestore.collection('packages').doc(packageId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final package = AddUmrahPackage(
          id: doc.id,
          title: data['title'] ?? '',
          price: data['price'] ?? '',
          startDate: data['startDate']?.toDate(),
          endDate: data['endDate']?.toDate(),
          note: data['note'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          itinerary: (data['itinerary'] as List<dynamic>?)?.map((day) =>
              ItineraryDay(
                date: day['date'].toDate(),
                activities: day['activities'] ?? '',
              )).toList() ?? [],
          services: (data['services'] as List<dynamic>?)?.map((service) =>
              PackageService(
                name: service['name'] ?? '',
                description: service['description'] ?? '',
              )).toList() ?? [],
        );
        _packageCache[packageId] = package;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching package details: $e');
    }
  }

  AddUmrahPackage? getPackageById(String? packageId) {
    if (packageId == null) return null;
    return _packageCache[packageId];
  }
  Future<String> _uploadFileToStorage(
      File file, String userId, String fileName) async {
    try {
      final ref = _storage.ref()
          .child('documents_image')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});

      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file to storage: $e');
      rethrow;
    }
  }

  Future<void> addOrUpdateDocument({
    required String userId,
    required String userName,
    required String documentType,
    required Map<String, dynamic> documentData,
    required File file,
    String? dob,
    String? issuingCountry,
    String? packageId,
    String? packageName,
  }) async {
    try {
      _isLoading = true;
      notifyListeners(); // Notify when loading starts

      final filePath = await _uploadFileToStorage(file, userId, file.path.split('/').last);

      final existingDoc = getUserDocument(userId);

      if (existingDoc != null) {
        // ✅ Put image URL directly into the documentType entry
        final updatedData = Map<String, dynamic>.from(documentData)
          ..['fileUrl'] = filePath;

        final updatedDoc = existingDoc.copyWith(
          name: userName,
          dob: dob ?? existingDoc.dob,
          issuingCountry: issuingCountry ?? existingDoc.issuingCountry,
          packageId: packageId,
          packageName: packageName,
          documents: {
            ...existingDoc.documents,
            documentType: updatedData,
          },
        );

        await _firestore
            .collection('user_wallet')
            .doc(updatedDoc.id)
            .update(updatedDoc.toFirestore());

        final index = _documents.indexWhere((doc) => doc.id == updatedDoc.id);
        if (index != -1) {
          _documents[index] = updatedDoc;
        }
      } else {
        final newDoc = Document(
          id: '',
          userId: userId,
          name: userName,
          documents: {
            documentType: {
              ...documentData,
              'fileUrl': filePath, // ✅ save inside doc
            },
          },
          uploadedFiles: [], // not used anymore for images
          uploadDate: DateTime.now().toString(),
          dob: dob,
          issuingCountry: issuingCountry,
          packageId: packageId,
          packageName: packageName,
        );

        final docRef = await _firestore.collection('user_wallet').add(newDoc.toFirestore());
        final createdDoc = newDoc.copyWith(id: docRef.id);
        _documents.add(createdDoc);
      }

      if (packageId != null && packageId.isNotEmpty) {
        await _fetchPackageDetails(packageId);
      }

    } catch (e) {
      debugPrint('Error adding/updating document: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners(); // Always notify when operation completes (success or error)
    }
  }

  Future<void> removeDocumentType(String userId, String documentType) async {
    try {
      final userDoc = getUserDocument(userId);
      if (userDoc != null) {
        userDoc.removeDocumentData(documentType);

        await _firestore
            .collection('user_wallet')
            .doc(userDoc.id)
            .update(userDoc.toFirestore());

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error removing document type: $e');
      rethrow;
    }
  }

  Future<void> updatePackageAssignment(String userId, {String? packageId, String? packageName}) async {
    try {
      final userDoc = getUserDocument(userId);
      print("User Doc ${userDoc!.userId}");
      if (userDoc != null) {
        final updatedDoc = userDoc.copyWith(
          packageId: packageId,
          packageName: packageName,
        );


        await _firestore
            .collection('user_wallet')
            .doc(userDoc.id)
            .update(updatedDoc.toFirestore());

        final index = _documents.indexWhere((doc) => doc.id == userDoc.id);
        if (index != -1) {
          _documents[index] = updatedDoc;
        }

        if (packageId != null && packageId.isNotEmpty) {
          await _fetchPackageDetails(packageId);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating package assignment: $e');
      rethrow;
    }
  }


  Future<void> removeDocument(String documentId) async {
    try {
      final document = _documents.firstWhere((doc) => doc.id == documentId);

      // Delete all files from storage
      for (final fileUrl in document.uploadedFiles) {
        try {
          final ref = _storage.refFromURL(fileUrl);
          await ref.delete();
        } catch (e) {
          debugPrint('Error deleting file from storage: $e');
        }
      }

      // Delete from Firestore
      await _firestore.collection('user_wallet').doc(documentId).delete();

      _documents.removeWhere((doc) => doc.id == documentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing document: $e');
      rethrow;
    }
  }
}