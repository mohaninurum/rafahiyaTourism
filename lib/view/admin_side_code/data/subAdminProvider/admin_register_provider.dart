import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/subAdminProvider/admin_login_provider.dart';
import 'package:rafahiyatourism/view/admin_side_code/data/utils/extensions.dart';

import '../../view/auth/subadmin_login_screen.dart';


class AdminRegisterProvider with ChangeNotifier {
  final TextEditingController masjidNameController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController imamNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController masjidPhoneNumberController = TextEditingController();
  String masjidSelectedCountryCode = "+91";



  final List<String> _countries = [
    'Afghanistan', 'Armenia', 'Azerbaijan', 'Bahrain', 'Bangladesh', 'Bhutan',
    'Brunei', 'Cambodia', 'China', 'Cyprus', 'Georgia', 'India', 'Indonesia',
    'Iran', 'Iraq', 'Israel', 'Japan', 'Jordan', 'Kazakhstan', 'Kuwait',
    'Kyrgyzstan', 'Laos', 'Lebanon', 'Malaysia', 'Maldives', 'Mongolia',
    'Myanmar', 'Nepal', 'North Korea', 'Oman', 'Pakistan', 'Palestine',
    'Philippines', 'Qatar', 'Russia', 'Saudi Arabia', 'Singapore', 'South Korea',
    'Sri Lanka', 'Syria', 'Taiwan', 'Tajikistan', 'Thailand', 'Timor-Leste',
    'Turkey', 'Turkmenistan', 'United Arab Emirates', 'Uzbekistan', 'Vietnam', 'Yemen',
    // Adding other continents for completeness
    'United States', 'Canada', 'United Kingdom', 'Germany', 'France', 'Italy',
    'Spain', 'Australia', 'Brazil', 'Argentina', 'Egypt', 'South Africa', 'Nigeria'
  ];

  List<String> get countries => _countries;
  String? _selectedCountry;

  String? get selectedCountry => _selectedCountry;

  set selectedCountry(String? value) {
    _selectedCountry = value;
    notifyListeners();
  }

  File? _pickedImage;
  String? _error;

  Position? _currentPosition;

  String selectedCountryCode = "+91";
  File? _proofDocument;
  bool _isUploading = false;
  String? _proofDocumentName;
  bool _isLoadingLocation = false;

  final ImagePicker _picker = ImagePicker();

  File? get pickedImage => _pickedImage;

  String? get error => _error;

  Position? get currentPosition => _currentPosition;

  bool get isLoadingLocation => _isLoadingLocation;

  File? get proofDocument => _proofDocument;

  bool get isUploading => _isUploading;

  String? get proofDocumentName => _proofDocumentName;

  double? _selectedLatitude;
  double? _selectedLongitude;

  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;

  // Add these setters
  set selectedLatitude(double? value) {
    _selectedLatitude = value;
    notifyListeners();
  }

  set selectedLongitude(double? value) {
    _selectedLongitude = value;
    notifyListeners();
  }

  void setSelectedLocation(String address, double latitude, double longitude) {
    addressController.text = address;
    selectedLatitude = latitude; // Use setter instead of direct assignment
    selectedLongitude = longitude; // Use setter instead of direct assignment
    notifyListeners();
  }

  void clearSelectedLocation() {
    selectedLatitude = null;
    selectedLongitude = null;
    notifyListeners();
  }

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;

  bool get isPasswordObscure => _isPasswordObscure;

  bool get isConfirmPasswordObscure => _isConfirmPasswordObscure;

  void togglePasswordVisibility() {
    _isPasswordObscure = !_isPasswordObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
    notifyListeners();
  }


  set currentPosition(value) {
    _currentPosition = value;
    notifyListeners();
  }

  void setLoadingLocation(bool value) {
    _isLoadingLocation = value;
    notifyListeners();
  }


  String? validateFields() {
    if (imamNameController.text.isEmpty) return "Imam Name is required";
    if (emailController.text.isEmpty) return "Email is required";
    if (!emailController.text.isValidEmail()) return "Enter a valid email";
    if (mobileNumberController.text.isEmpty) return "Phone number is required";
    if (!mobileNumberController.text.isValidMobileNumber()) {
      return "Enter a valid mobile number (e.g., +923XXXXXXXXX or 03XXXXXXXXX)";
    }

    if (cityController.text.isEmpty) return "City is required";
    if (passwordController.text.isEmpty) return "Password is required";
    if (passwordController.text.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (passwordController.text != confirmPasswordController.text) {
      return "Passwords don't match";
    }
    if (_proofDocument == null) return "Proof of association document is required";
    // if (proofDocument == null) return "Verification document is required";
    return null;
  }


  String? validateFieldsRegisterTwo() {
    if (masjidPhoneNumberController.text.isEmpty) return "Masjid phone number is required";
    if (!masjidPhoneNumberController.text.isValidMobileNumber()) {
      return "Enter a valid masjid mobile number (e.g., +923XXXXXXXXX or 03XXXXXXXXX)";
    }

    if (masjidNameController.text.isEmpty) return "Masjid Name is required";
    if (pinCodeController.text.isEmpty) return "PinCode is required";
    if (addressController.text.isEmpty) return "Address is required";

    // Add country validation
    final extractedCountry = extractCountryFromAddress(addressController.text);
    if (extractedCountry == null && _selectedCountry == null) {
      return "Please select your country from the dropdown";
    }

    return null;
  }

  Future<void> pickImageFromCamera(ImageSource source) async {
    try {
      _error = null;
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        _pickedImage = File(image.path);
      } else {
        _error = "No image selected.";
      }
    } catch (e) {
      _error = "Failed to pick image: $e";
    }
    notifyListeners();
  }

  // Future<void> pickProofDocument(BuildContext context) async {
  //   try {
  //     _isUploading = true;
  //     _proofDocument = null;
  //     _proofDocumentName = null;
  //     notifyListeners();
  //
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['pdf', 'doc', 'docx'],
  //     );
  //
  //     if (result != null) {
  //       _proofDocument = File(result.files.single.path!);
  //       _proofDocumentName = result.files.single.name;
  //       _error = null;
  //     } else {
  //       _error = "No document selected.";
  //     }
  //   } catch (e) {
  //     _error = "Failed to pick document: $e";
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Failed to pick document: $e")));
  //   } finally {
  //     _isUploading = false;
  //     notifyListeners();
  //   }
  // }

  // Future<void> pickProofDocument(BuildContext context) async {
  //   try {
  //     _isUploading = true;
  //     _proofDocument = null;
  //     _proofDocumentName = null;
  //     notifyListeners();
  //
  //     final source = await showModalBottomSheet<ImageSource>(
  //       context: context,
  //       builder: (ctx) => Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text("Camera"),
  //             onTap: () => Navigator.pop(ctx, ImageSource.camera),
  //           ),
  //           ListTile(
  //             leading: const Icon(Icons.photo_library),
  //             title: const Text("Gallery"),
  //             onTap: () => Navigator.pop(ctx, ImageSource.gallery),
  //           ),
  //         ],
  //       ),
  //     );
  //
  //     if (source != null) {
  //       final pickedFile = await _picker.pickImage(source: source);
  //       if (pickedFile != null) {
  //         _proofDocument = File(pickedFile.path);
  //         _proofDocumentName = pickedFile.name;
  //         _error = null;
  //       } else {
  //         _error = "No image selected.";
  //       }
  //     }
  //   } catch (e) {
  //     _error = "Failed to pick proof image: $e";
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text("Failed to pick proof image: $e")));
  //   } finally {
  //     _isUploading = false;
  //     notifyListeners();
  //   }
  // }


  Future<void> registerSubAdmin(BuildContext context) async {
    final adminLoginProvider = Provider.of<AdminsLoginProvider>(
      context,
      listen: false,
    );
    final validationError = validateFields() ?? validateFieldsRegisterTwo();
    if (validationError != null) {
      context.showSnackBarMessage(validationError);
      return;
    }

    try {
      _isUploading = true;
      notifyListeners();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('subAdmin')
          .where('masjidName', isEqualTo: masjidNameController.text.trim())
          .where('pinCode', isEqualTo: pinCodeController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        context.showSnackBarMessage("Masjid Name and PinCode already exist. You can't sign up.");
        _isUploading = false;
        notifyListeners();
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception("User ID is null");

      String imageUrl = '';
      if (_pickedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profileImages')
            .child('$uid.jpg');
        await ref.putFile(_pickedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      String proofUrl = '';
      if (_proofDocument != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('proofDocuments')
            .child('$uid.jpg');
        await ref.putFile(_proofDocument!);
        proofUrl = await ref.getDownloadURL();
      }

      // Use enhanced country extraction
      final String? country = extractCountryFromAddress(addressController.text);

      await FirebaseFirestore.instance.collection("subAdmin").doc(uid).set({
        'uid': uid,
        'imamName': imamNameController.text.trim(),
        'email': emailController.text.trim(),
        'mobileNumber': '$selectedCountryCode${mobileNumberController.text.trim()}',
        'masjidPhoneNumber': '$masjidSelectedCountryCode${masjidPhoneNumberController.text.trim()}',
        'city': cityController.text.trim(),
        'masjidName': masjidNameController.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'address': addressController.text.trim(),
        'imageUrl': imageUrl,
        'proofUrl': proofUrl,
        'proofDocumentName': _proofDocumentName,
        'location': (selectedLatitude != null && selectedLongitude != null)
            ? {
          'latitude': selectedLatitude!,
          'longitude': selectedLongitude!,
          'country': country, // Use the extracted/selected country
        }
            : (_currentPosition != null
            ? {
          'latitude': _currentPosition!.latitude,
          'longitude': _currentPosition!.longitude,
          'country': country, // Use the extracted/selected country
        }
            : null),
        'userType': adminLoginProvider.userType,
        'successfullyRegistered': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      context.showSnackBarMessage("Sub-admin registered successfully");
      clearAllData();

      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SubAdminLoginScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      // ... your existing error handling ...
    } catch (e) {
      context.showSnackBarMessage("Error: ${e.toString()}");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Update clearAllData to reset country selection
  void clearAllData() {
    masjidNameController.clear();
    masjidPhoneNumberController.clear();
    pinCodeController.clear();
    mobileNumberController.clear();
    addressController.clear();
    emailController.clear();
    cityController.clear();
    imamNameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    _pickedImage = null;
    _proofDocument = null;
    _proofDocumentName = null;
    _currentPosition = null;
    selectedLatitude = null;
    selectedLongitude = null;
    _selectedCountry = null; // Clear selected country

    selectedCountryCode = "+91";
    masjidSelectedCountryCode = "+91";

    _isPasswordObscure = true;
    _isConfirmPasswordObscure = true;

    notifyListeners();
  }


  String? extractCountryFromAddress(String address) {
    // First, check if user manually selected a country
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      return _selectedCountry;
    }

    // Then try to extract from address
    for (final country in _countries) {
      if (address.toLowerCase().contains(country.toLowerCase())) {
        return country;
      }
    }

    // If no country found in address, return null
    return null;
  }


  void removeProofDocument() {
    _proofDocument = null;
    _proofDocumentName = null;
    notifyListeners();
  }

  Future<void> pickProofDocument(BuildContext context) async {
    try {
      _isUploading = true;
      notifyListeners();

      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (ctx) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      );

      if (source != null) {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          _proofDocument = File(pickedFile.path);
          _proofDocumentName = "Proof_${DateTime.now().millisecondsSinceEpoch}.jpg";
          _error = null;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Proof document added successfully"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _error = "No image selected.";
        }
      }
    } catch (e) {
      _error = "Failed to pick proof image: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick proof image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  void clearImage() {
    _pickedImage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    masjidNameController.dispose();
    masjidPhoneNumberController.dispose();
    pinCodeController.dispose();
    mobileNumberController.dispose();
    addressController.dispose();
    imamNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
