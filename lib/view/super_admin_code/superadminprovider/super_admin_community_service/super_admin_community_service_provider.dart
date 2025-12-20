import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/community_service/community_service_model.dart';

class CommunityServiceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SuperAdminCommunityServiceModel> _services = [];

  List<SuperAdminCommunityServiceModel> get services => _services;

  Future<void> fetchServices() async {
    try {
      final snapshot = await _firestore.collection('community_services').get();
      _services = snapshot.docs
          .map((doc) => SuperAdminCommunityServiceModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> addService(SuperAdminCommunityServiceModel service) async {
    try {
      final docRef = await _firestore
          .collection('community_services')
          .add(service.toMap());
      _services.add(SuperAdminCommunityServiceModel(
        id: docRef.id,
        title: service.title,
        icon: service.icon,
        descriptions: service.descriptions,
        locationContacts: service.locationContacts,
      ));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> updateService(SuperAdminCommunityServiceModel service) async {
    try {
      await _firestore
          .collection('community_services')
          .doc(service.id)
          .update(service.toMap());
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _services[index] = service;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _firestore.collection('community_services').doc(id).delete();
      _services.removeWhere((service) => service.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }
}