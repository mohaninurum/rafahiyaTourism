import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AppSettingsProvider with ChangeNotifier {
  String _introTitle = '';
  String _introTagline = '';
  String _introDescription = '';
  String _introSecondaryDescription = '';

  String get introTitle => _introTitle;
  String get introTagline => _introTagline;
  String get introDescription => _introDescription;
  String get introSecondaryDescription => _introSecondaryDescription;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController taglineController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController secondaryDescriptionController = TextEditingController();

  String _aboutPdfUrl = '';

  String get aboutPdfUrl => _aboutPdfUrl;
// Contact information properties
  String _contactPhone = '';
  String _contactEmail = '';
  String _contactAddress = '';
  String _contactWebsite = '';
  String _contactWhatsApp = '';
  String _contactFacebook = '';
  String _contactInstagram = '';
  String _contactTwitter = '';

// Getters for contact information
  String get contactPhone => _contactPhone;
  String get contactEmail => _contactEmail;
  String get contactAddress => _contactAddress;
  String get contactWebsite => _contactWebsite;
  String get contactWhatsApp => _contactWhatsApp;
  String get contactFacebook => _contactFacebook;
  String get contactInstagram => _contactInstagram;
  String get contactTwitter => _contactTwitter;

// Controllers for contact form
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController whatsappController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();

  void initializeContactControllers() {
    phoneController.text = _contactPhone;
    emailController.text = _contactEmail;
    addressController.text = _contactAddress;
    websiteController.text = _contactWebsite;
    whatsappController.text = _contactWhatsApp;
    facebookController.text = _contactFacebook;
    instagramController.text = _contactInstagram;
    twitterController.text = _contactTwitter;
  }

  void initializeControllers() {
    titleController.text = _introTitle;
    taglineController.text = _introTagline;
    descriptionController.text = _introDescription;
    secondaryDescriptionController.text = _introSecondaryDescription;
  }



  Future<void> fetchIntroContent() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('appContent')
          .doc('introScreen')
          .get();

      if (doc.exists) {
        _introTitle = doc['title'] ?? '';
        _introTagline = doc['tagline'] ?? '';
        _introDescription = doc['description'] ?? '';
        _introSecondaryDescription = doc['secondaryDescription'] ?? '';

        // Update controllers with new values
        titleController.text = _introTitle;
        taglineController.text = _introTagline;
        descriptionController.text = _introDescription;
        secondaryDescriptionController.text = _introSecondaryDescription;

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching intro content: $e');
      }
    }
  }

  Future<bool> updateIntroContent() async {
    try {
      await FirebaseFirestore.instance
          .collection('appContent')
          .doc('introScreen')
          .set({
        'title': titleController.text,
        'tagline': taglineController.text,
        'description': descriptionController.text,
        'secondaryDescription': secondaryDescriptionController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _introTitle = titleController.text;
      _introTagline = taglineController.text;
      _introDescription = descriptionController.text;
      _introSecondaryDescription = secondaryDescriptionController.text;

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating intro content: $e');
      }
      return false;
    }
  }

  List<Map<String, String>> _termsContent = [];

  List<Map<String, String>> get termsContent => _termsContent;




  String get formattedTermsContent {
    return _termsContent.map((section) {
      return '${section['heading']}\n${section['description']}\n\n';
    }).join();
  }


  Future<void> fetchTermsContent() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('appContent')
          .doc('termsConditions')
          .get();

      if (doc.exists && doc['content'] != null) {
        // Parse the content from Firestore
        List<dynamic> contentList = doc['content'];
        _termsContent = contentList.map((item) {
          return {
            'heading': (item['heading'] ?? '').toString(),
            'description': (item['description'] ?? '').toString(),
          };
        }).toList();
      } else {
        // If no data exists, create an empty section
        _termsContent = [
          {'heading': '', 'description': ''}
        ];
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching terms content: $e');
      }
      // Even if there's an error, ensure we have at least one section
      if (_termsContent.isEmpty) {
        _termsContent = [
          {'heading': '', 'description': ''}
        ];
        notifyListeners();
      }
    }
  }


  Future<bool> updateTermsContent() async {
    try {
      await FirebaseFirestore.instance
          .collection('appContent')
          .doc('termsConditions')
          .set({
        'content': _termsContent,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating terms content: $e');
      }
      return false;
    }
  }

  void addNewSection() {
    _termsContent.add({
      'heading': '',
      'description': '',
    });
    notifyListeners();
  }


  void removeSection(int index) {
    if (_termsContent.length > 1) {
      _termsContent.removeAt(index);
      notifyListeners();
    }
  }


  void updateSectionHeading(int index, String heading) {
    if (index >= 0 && index < _termsContent.length) {
      _termsContent[index]['heading'] = heading;
      notifyListeners();
    }
  }

  void updateSectionDescription(int index, String description) {
    if (index >= 0 && index < _termsContent.length) {
      _termsContent[index]['description'] = description;
      notifyListeners();
    }
  }


  Future<void> fetchAboutPdfUrl() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('appContent')
          .doc('aboutPdf')
          .get();

      if (doc.exists) {
        _aboutPdfUrl = doc['pdfUrl'] ?? '';
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching about PDF URL: $e');
      }
    }
  }

  Future<bool> updateAboutPdf(String pdfUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('appContent')
          .doc('aboutPdf')
          .set({
        'pdfUrl': pdfUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _aboutPdfUrl = pdfUrl;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating about PDF: $e');
      }
      return false;
    }
  }


  Future<void> fetchContactInfo() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('appContent')
          .doc('contactInfo')
          .get();

      if (doc.exists) {
        _contactPhone = doc['phone'] ?? '';
        _contactEmail = doc['email'] ?? '';
        _contactAddress = doc['address'] ?? '';
        _contactWebsite = doc['website'] ?? '';
        _contactWhatsApp = doc['whatsapp'] ?? '';
        _contactFacebook = doc['facebook'] ?? '';
        _contactInstagram = doc['instagram'] ?? '';
        _contactTwitter = doc['twitter'] ?? '';

        // Update controllers
        initializeContactControllers();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching contact info: $e');
      }
    }
  }

// Update contact information
  Future<bool> updateContactInfo() async {
    try {
      await FirebaseFirestore.instance
          .collection('appContent')
          .doc('contactInfo')
          .set({
        'phone': phoneController.text,
        'email': emailController.text,
        'address': addressController.text,
        'website': websiteController.text,
        'whatsapp': whatsappController.text,
        'facebook': facebookController.text,
        'instagram': instagramController.text,
        'twitter': twitterController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      _contactPhone = phoneController.text;
      _contactEmail = emailController.text;
      _contactAddress = addressController.text;
      _contactWebsite = websiteController.text;
      _contactWhatsApp = whatsappController.text;
      _contactFacebook = facebookController.text;
      _contactInstagram = instagramController.text;
      _contactTwitter = twitterController.text;

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating contact info: $e');
      }
      return false;
    }
  }


  @override
  void dispose() {
    titleController.dispose();
    taglineController.dispose();
    descriptionController.dispose();
    secondaryDescriptionController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    websiteController.dispose();
    whatsappController.dispose();
    facebookController.dispose();
    instagramController.dispose();
    twitterController.dispose();
    super.dispose();
  }
}