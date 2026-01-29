import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../view/model/notification_model.dart';
class NotificationListProvider extends ChangeNotifier {
  bool isLoading=false;
  NotificationResponse? notificationResponse;

void fetchNotificationsApi({
    required String userId,
  }) async {
    isLoading= true;
    notifyListeners();
    try {
      final uri =
      Uri.parse('https://us-central1-rafahiya-tourism.cloudfunctions.net/getNotifications');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        notificationResponse=  NotificationResponse.fromJson(decodedJson);
        isLoading= false;
        notifyListeners();
      }
    } catch (e) {
      isLoading= false;
      print('Fetch Notification Error: $e');
      notifyListeners();
    }
  }

}