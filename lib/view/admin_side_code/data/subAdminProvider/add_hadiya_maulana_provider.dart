
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../const/error_handler.dart';
import '../models/hadiya_model.dart';

class HadiyaProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  List<HadiyaModel> _allHadiyaList = [];

  List<HadiyaModel> _hadiyaList = [];
  List<HadiyaModel> get hadiyaList => _hadiyaList;

  final Set<String> _pendingTypes = {};
  Set<String> get pendingTypes => _pendingTypes;

  StreamSubscription? _subscription;

  HadiyaProvider({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    ErrorHandler? errorHandler,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController bankDetailsController = TextEditingController();
  final TextEditingController accountHolderNameController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController paymentLinkController = TextEditingController();

  File? _qrImage;
  bool _isLoading = false;
  String? _error;

  String? _selectedHadiyaTitle;
  String? get selectedHadiyaTitle => _selectedHadiyaTitle;

  File? get qrImage => _qrImage;
  bool get isLoading => _isLoading;
  String? get error => _error;


  bool get isSaveDisabled {
    if (_selectedHadiyaTitle == null) return true;

    return _allHadiyaList.any((h) => h.type == _selectedHadiyaTitle);
  }

  bool isOptionDisabled(String type) {
    // Disable if ANY hadiya exists for this type
    return _allHadiyaList.any((h) => h.type == type);
  }

  // bool get isSaveDisabled {
  //   if (_selectedHadiyaTitle == null) return true;
  //   final approvedExists = _hadiyaList.any((h) => h.type == _selectedHadiyaTitle);
  //   final pendingExists = _pendingTypes.contains(_selectedHadiyaTitle);
  //   return approvedExists || pendingExists;
  // }


  void setHadiyaTitle(String value) {
    // Clear form when switching between options
    if (_selectedHadiyaTitle != value) {
      _clearForm();
    }
    _selectedHadiyaTitle = value;
    notifyListeners();
  }

  bool _showPaymentLink = false;
  bool get showPaymentLink => _showPaymentLink;

  set showPaymentLink(bool value) {
    _showPaymentLink = value;
    notifyListeners();
  }

  Future<void> pickQRImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        _qrImage = File(image.path);
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _handleError(e, "Image pick failed");
    }
  }

  void removeQRImage() {
    _qrImage = null;
    notifyListeners();
  }

  Future<bool> submitHadiyaDetails(String subAdminId) async {
    if (!_validateForm()) return false;

    try {
      _isLoading = true;
      notifyListeners();

      String? imageUrl;
      if (_qrImage != null) {
        imageUrl = await _uploadQRImage();
      }

      await _saveHadiyaDetails(subAdminId, imageUrl);

      if (_selectedHadiyaTitle != null) {
        _pendingTypes.add(_selectedHadiyaTitle!);
      }

      _clearForm();

      // Clear selection after successful submission
      _selectedHadiyaTitle = null;
      notifyListeners();

      return true;
    } catch (e) {
      _handleError(e, "Submission failed");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearForm() {
    titleController.clear();
    bankDetailsController.clear();
    accountHolderNameController.clear();
    accountController.clear();
    ifscController.clear();
    paymentLinkController.clear();
    _qrImage = null;
    _showPaymentLink = false;
    _error = null;
    // Don't clear _selectedHadiyaTitle here anymore
    notifyListeners();
  }


  // bool isOptionDisabled(String type) {
  //   final approved = _hadiyaList.any((h) => h.type == type);
  //   final pending = _pendingTypes.contains(type);
  //   return approved || pending;
  // }

  Future<String?> _uploadQRImage() async {
    try {
      final ref = _storage.ref(
        'hadiya_qr/${DateTime.now().millisecondsSinceEpoch}',
      );
      await ref.putFile(_qrImage!);
      return await ref.getDownloadURL();
    } catch (e) {
      _handleError(e, "Image upload failed");
      return null;
    }
  }

  Future<void> _saveHadiyaDetails(String subAdminId, String? imageUrl) async {
    final Map<String, dynamic> data = {
      'subAdminId': subAdminId,
      'type': selectedHadiyaTitle,
      'bankDetails': bankDetailsController.text,
      'accountHolderName': accountHolderNameController.text,
      'accountNumber': accountController.text,
      'ifscCode': ifscController.text,
      'qrCodeUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'allowed': false,
    };

    if (paymentLinkController.text.isNotEmpty) {
      data['paymentLink'] = paymentLinkController.text;
    }

    await _firestore
        .collection('mosques')
        .doc(subAdminId)
        .collection('hadiyaDetails')
        .add(data);
  }

  bool _validateForm() {
    if (_selectedHadiyaTitle == null ||
        bankDetailsController.text.isEmpty ||
        accountHolderNameController.text.isEmpty ||
        accountController.text.isEmpty ||
        ifscController.text.isEmpty ||
        _qrImage == null) {
      _error = "All fields (except Payment Link) are required, including QR Image";
      notifyListeners();
      return false;
    }
    return true;
  }

  void listenToHadiya(String subAdminId) {
    _subscription?.cancel();

    _subscription = _firestore
        .collection('mosques')
        .doc(subAdminId)
        .collection('hadiyaDetails')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Store ALL hadiyas
      _allHadiyaList = snapshot.docs
          .map((doc) => HadiyaModel.fromDocument(doc))
          .toList();

      // Keep approved list for other uses
      _hadiyaList = _allHadiyaList.where((h) => h.allowed == true).toList();

      // Update pending types based on unapproved entries
      _pendingTypes.clear();
      _pendingTypes.addAll(
        _allHadiyaList
            .where((h) => h.allowed == false)
            .map((h) => h.type)
            .where((type) => type != null)
            .cast<String>(),
      );

      notifyListeners();
    });
  }

  List<HadiyaModel> get approvedHadiya =>
      _hadiyaList.where((h) => h.allowed == true).toList();

  List<HadiyaModel> get pendingHadiya =>
      _hadiyaList.where((h) => h.allowed == false).toList();

// In your updateHadiya method, modify the QR code handling:
  Future<void> updateHadiya({
    required String subAdminId,
    required String documentId,
    required Map<String, dynamic> updateData,
    dynamic qrFile,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Only upload new QR code if provided
      if (qrFile != null && qrFile is XFile) {
        final file = File(qrFile.path);
        if (!file.existsSync()) {
          throw Exception("QR file not found at ${qrFile.path}");
        }

        final ref = _storage.ref().child('hadiya_qr').child('$documentId.png');
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        updateData['qrCodeUrl'] = downloadUrl;
      }


      await _firestore
          .collection('mosques')
          .doc(subAdminId)
          .collection('hadiyaDetails')
          .doc(documentId)
          .set(updateData, SetOptions(merge: true));
    } catch (e, st) {
      _handleError(e, "Failed to update Hadiya");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHadiya({
    required String subAdminId,
    required String documentId,
    String? qrCodeUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('mosques')
          .doc(subAdminId)
          .collection('hadiyaDetails')
          .doc(documentId)
          .delete();

      if (qrCodeUrl != null && qrCodeUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(qrCodeUrl);
          await ref.delete();
        } catch (e) {
          debugPrint("QR Image delete failed: $e");
        }
      }
    } catch (e) {
      _handleError(e, "Failed to delete Hadiya");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // void _clearForm() {
  //   titleController.clear();
  //   bankDetailsController.clear();
  //   accountHolderNameController.clear();
  //   accountController.clear();
  //   ifscController.clear();
  //   paymentLinkController.clear();
  //   _qrImage = null;
  //   _showPaymentLink = false;
  //   _error = null;
  //
  //   // CLEAR the selection after successful submission
  //   _selectedHadiyaTitle = null;
  //
  //   notifyListeners();
  // }

  // Add a method to completely reset the form including selection
  void resetForm() {
    _selectedHadiyaTitle = null;
    _clearForm();
  }

  void _handleError(dynamic error, String contextMessage) {
    _error = "$contextMessage: ${ErrorHandler.showError(error)}";
    ErrorHandler.showError(error);
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    bankDetailsController.dispose();
    accountHolderNameController.dispose(); // NEW DISPOSE
    accountController.dispose();
    paymentLinkController.dispose();
    _subscription?.cancel();
    super.dispose();
  }
}