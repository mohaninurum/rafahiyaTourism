import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../const/color.dart';
import '../utils/language/app_strings.dart';
import '../utils/model/auth/auth_user_model.dart';
import '../utils/services/get_time_zone.dart';

class SignupProvider with ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  File? _profileImage;
  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Country related properties
  final List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo (Congo-Brazzaville)',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Democratic Republic of the Congo',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Liechtenstein',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Marshall Islands',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar (Burma)',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'North Macedonia',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Palestine',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States of America',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe',
  ];



  String? _selectedCountry;

  bool get isPasswordObscure => _isPasswordObscure;
  bool get isConfirmPasswordObscure => _isConfirmPasswordObscure;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  File? get profileImage => _profileImage;
  List<String> get countries => _countries;
  String? get selectedCountry => _selectedCountry;


  Future<void> savePlayerIdToFirestore(String uid, String collectionName) async {
    try {
      // Always request permission first
      await OneSignal.Notifications.requestPermission(true);

      // Wait 2 seconds so OneSignal can generate the ID
      await Future.delayed(Duration(seconds: 2));

      final playerId = OneSignal.User.pushSubscription.id;
      final isSubscribed = OneSignal.User.pushSubscription.optedIn;

      print("🔍 Player ID (after delay): $playerId");
      print("🔍 Is Subscribed: $isSubscribed");

      if (playerId != null && playerId.isNotEmpty && isSubscribed == true) {
        await FirebaseFirestore.instance
            .collection(collectionName)
            .doc(uid)
            .update({'playerId': playerId});

        print("✅ Player ID saved to Firestore: $playerId");
      } else {
        print("⚠️ Player ID still NULL. Will retry on next login/app open.");
      }
    } catch (e) {
      print("❌ Error saving Player ID: $e");
    }
  }



  void setCountry(String country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscure = !_isPasswordObscure;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordObscure = !_isConfirmPasswordObscure;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = '${AppStrings.getString('failedPickImage', currentLocale)}: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearImage() {
    _profileImage = null;
    notifyListeners();
  }

  void showImagePickerBottomSheet(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              AppStrings.getString('chooseProfilePhoto', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  context,
                  icon: Icons.camera_alt,
                  text: AppStrings.getString('camera', currentLocale),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera, context);
                  },
                ),
                _buildImagePickerOption(
                  context,
                  icon: Icons.photo_library,
                  text: AppStrings.getString('gallery', currentLocale),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery, context);
                  },
                ),
                if (_profileImage != null)
                  _buildImagePickerOption(
                    context,
                    icon: Icons.delete,
                    text: AppStrings.getString('remove', currentLocale),
                    onTap: () {
                      Navigator.pop(context);
                      clearImage();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _uploadImageToStorage(File image, String userId, BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_profile')
          .child(userId)
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      final uploadTask = ref.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});

      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('${AppStrings.getString('failedUploadImage', currentLocale)}: $e');
    }
  }

  Widget _buildImagePickerOption(
      BuildContext context, {
        required IconData icon,
        required String text,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: AppColors.mainColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }

  Future<bool> registerUser(BuildContext context) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    if (!_validateForm(currentLocale)) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String? imageUrl;

      // Upload image if selected
      if (_profileImage != null) {
        imageUrl = await _uploadImageToStorage(_profileImage!, userCredential.user!.uid, context);
      }

      // String currentTimeZone = await GetTimeZone.setupTimezone();
      // String topic = currentTimeZone.replaceAll('/', '_');
      // await FirebaseMessaging.instance.subscribeToTopic(topic);

      final user = AuthUserModel(
        id: userCredential.user?.uid,
        fullName: fullNameController.text.trim(),
        pinCode: pinCodeController.text.trim(),
        mobileNumber: mobileNumberController.text.trim(),
        city: cityController.text.trim(),
        country: _selectedCountry ?? '', // Use selected country
        email: emailController.text.trim(),
        profileImage: imageUrl ?? '',
        timeZone: ''
      );

      await _saveUserToFirestore(user);



      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e, currentLocale);
      return false;
    } catch (e) {
      _errorMessage = AppStrings.getString('unexpectedError', currentLocale);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveUserToFirestore(AuthUserModel user) async {
    if (user.id == null) throw Exception('User ID is null');

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.id)
        .set(user.toMap());

    // Save player ID FIRST before navigation
    await savePlayerIdToFirestore(user.id.toString(), 'subAdmin');
  }

  bool _validateForm(String languageCode) {
    if (fullNameController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterFullName', languageCode);
      notifyListeners();
      return false;
    }

    if (pinCodeController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterPincode', languageCode);
      notifyListeners();
      return false;
    }

    if (mobileNumberController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterMobileNumber', languageCode);
      notifyListeners();
      return false;
    } else if (!RegExp(r'^[0-9]{10,15}$').hasMatch(mobileNumberController.text.trim())) {
      _errorMessage = AppStrings.getString('enterValidMobile', languageCode);
      notifyListeners();
      return false;
    }

    if (cityController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterCity', languageCode);
      notifyListeners();
      return false;
    }

    // Updated country validation
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _errorMessage = AppStrings.getString('enterCountry', languageCode);
      notifyListeners();
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterEmail', languageCode);
      notifyListeners();
      return false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text.trim())) {
      _errorMessage = AppStrings.getString('enterValidEmail', languageCode);
      notifyListeners();
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('enterPassword', languageCode);
      notifyListeners();
      return false;
    } else if (passwordController.text.length < 6) {
      _errorMessage = AppStrings.getString('passwordLength', languageCode);
      notifyListeners();
      return false;
    }

    if (confirmPasswordController.text.trim().isEmpty) {
      _errorMessage = AppStrings.getString('confirmPassword', languageCode);
      notifyListeners();
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = AppStrings.getString('passwordsNotMatch', languageCode);
      notifyListeners();
      return false;
    }

    return true;
  }

  void _handleFirebaseError(FirebaseAuthException e, String languageCode) {
    switch (e.code) {
      case 'email-already-in-use':
        _errorMessage = AppStrings.getString('emailAlreadyInUse', languageCode);
        break;
      case 'invalid-email':
        _errorMessage = AppStrings.getString('invalidEmail', languageCode);
        break;
      case 'operation-not-allowed':
        _errorMessage = AppStrings.getString('operationNotAllowed', languageCode);
        break;
      case 'weak-password':
        _errorMessage = AppStrings.getString('weakPassword', languageCode);
        break;
      default:
        _errorMessage = '${AppStrings.getString('registrationError', languageCode)}: ${e.message}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    pinCodeController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}