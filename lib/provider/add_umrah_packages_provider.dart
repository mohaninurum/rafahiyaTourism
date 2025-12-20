import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../utils/model/add_umrah_packages_model.dart';

class AddUmrahPackageProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<AddUmrahPackage> _packages = [];

  List<AddUmrahPackage> get packages => _packages;

  Future<String> uploadImage(File imageFile) async {
    try {
      print('Starting image upload...');
      final ref = _storage.ref().child(
        'umrah_packages/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked': 'picker'},
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask.whenComplete(() {});

      print('Upload completed: ${snapshot.state}');

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> addPackage(AddUmrahPackage package, {File? imageFile}) async {
    try {
      String imageUrl = package.imageUrl;

      // Upload new image if provided (and it's not already a URL)
      if (imageFile != null && !imageUrl.startsWith('http')) {
        imageUrl = await uploadImage(imageFile);
      }

      final docRef = await _firestore.collection('packages').add({
        'title': package.title,
        'price': package.price,
        'startDate': package.startDate,
        'endDate': package.endDate,
        'note': package.note,
        'imageUrl': imageUrl,
        'itinerary': package.itinerary.map((day) => {
          'date': day.date,
          'activities': day.activities,
        }).toList(),
        'services': package.services.map((service) => {
          'name': service.name,
          'description': service.description,
        }).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      _packages.add(package.copyWith(id: docRef.id, imageUrl: imageUrl));
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add package: $e');
    }
  }

  Future<void> updatePackage(AddUmrahPackage package, {File? imageFile}) async {
    try {
      String imageUrl = package.imageUrl;

      // Upload new image if provided (and it's not already a URL)
      if (imageFile != null && !imageUrl.startsWith('http')) {
        imageUrl = await uploadImage(imageFile);
      }

      await _firestore.collection('packages').doc(package.id).update({
        'title': package.title,
        'price': package.price,
        'startDate': package.startDate,
        'endDate': package.endDate,
        'note': package.note,
        'imageUrl': imageUrl,
        'itinerary': package.itinerary.map((day) => {
          'date': day.date,
          'activities': day.activities,
        }).toList(),
        'services': package.services.map((service) => {
          'name': service.name,
          'description': service.description,
        }).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final index = _packages.indexWhere((p) => p.id == package.id);
      if (index != -1) {
        _packages[index] = package.copyWith(imageUrl: imageUrl);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update package: $e');
    }
  }

  Future<void> removePackage(String packageId) async {
    try {
      await _firestore.collection('packages').doc(packageId).delete();
      _packages.removeWhere((p) => p.id == packageId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete package: $e');
    }
  }

  Future<void> fetchPackages() async {
    try {
      final snapshot = await _firestore.collection('packages').orderBy('createdAt', descending: true).get();
      _packages = snapshot.docs.map((doc) {
        final data = doc.data();
        return AddUmrahPackage(
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
              )
          ).toList() ?? [],
          services: (data['services'] as List<dynamic>?)?.map((service) =>
              PackageService(
                name: service['name'] ?? '',
                description: service['description'] ?? '',
              )
          ).toList() ?? [],
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch packages: $e');
    }
  }

  List<DateTime> generateDateRange(DateTime startDate, DateTime endDate) {
    final days = endDate.difference(startDate).inDays + 1;
    return List.generate(days, (i) => startDate.add(Duration(days: i)));
  }
}