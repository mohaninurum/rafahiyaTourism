import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'get_time_zone.dart';

class MosqueSubscriptionManager {
  static const String _storageKey = "selectedMosques";

  /// ✅ Get selected mosques from local storage
  static Future<List<String>> getSelectedMosques() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_storageKey) ?? [];
  }

  /// ✅ Save & Sync mosque subscriptions
  static Future<void> updateMosqueSubscriptions(

      List<String> newMosqueIds) async {

    if (newMosqueIds.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final oldMosqueIds = prefs.getStringList(_storageKey) ?? [];

    String newMosqueId = newMosqueIds.first;
    String? oldMosqueId =
    oldMosqueIds.isNotEmpty ? oldMosqueIds.first : null;

    // ✅ Agar same mosque hai to kuch mat karo
    if (oldMosqueId == newMosqueId) {
      print("Same mosque - no change");
      return;
    }

    // 🔴 Old unsubscribe
    if (oldMosqueId != null) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(oldMosqueId);
    }

    // 🟢 New subscribe
    await FirebaseMessaging.instance
        .subscribeToTopic(newMosqueId);

    await GetTimeZone.checkOrCreateTimeZone(true, newMosqueId);

    // Local save (sirf first)
    await prefs.setStringList(_storageKey, [newMosqueId]);


    //   List<String> newMosqueIds) async {
    // final prefs = await SharedPreferences.getInstance();
    // final oldMosqueIds = prefs.getStringList(_storageKey) ?? [];
    //
    // String newMosqueId = newMosqueIds.first;
    //
    // // 🔴 Agar pehle koi aur mosque subscribed tha to unsubscribe karo
    // if (oldMosqueIds.isNotEmpty) {
    //   String oldMosqueId = oldMosqueIds.first;
    //   if (oldMosqueId == newMosqueId) {
    //     print("Same mosque - no change");
    //     return;
    //   }
    //   if (oldMosqueId != newMosqueId) {
    //     await FirebaseMessaging.instance
    //         .unsubscribeFromTopic(oldMosqueId);
    //   }
    // }
    // // 🔴 Unsubscribe removed mosques
    // for (String oldId in oldMosqueIds) {
    //   if (!newMosqueIds[0].contains(oldId)) {
    //     await FirebaseMessaging.instance
    //         .unsubscribeFromTopic("mosque_${oldId[0]}");
    //   }
    // }

    // 🟢 Subscribe new mosques
    // for (String newId in newMosqueIds) {
    //   if (!oldMosqueIds.contains(newId)) {
    //     await FirebaseMessaging.instance
    //         .subscribeToTopic("mosque_$newId");
    //     await GetTimeZone.checkOrCreateTimeZone( true, "mosque_$newId");
    //   }
    // }
    // print(newMosqueId);
    // await FirebaseMessaging.instance
    //     .subscribeToTopic(newMosqueId);
    // await GetTimeZone.checkOrCreateTimeZone( true, newMosqueId);
    //
    // // Save locally
    // await prefs.setStringList(_storageKey, newMosqueIds);

    // Save in Firestore
    String userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({
      "timeZone": newMosqueId,
    });
  }

  /// ✅ Unsubscribe all mosques (Logout case)
  static Future<void> unsubscribeAll() async {
    final prefs = await SharedPreferences.getInstance();
    final mosqueIds = prefs.getStringList(_storageKey) ?? [];

    for (String id in mosqueIds) {
      await FirebaseMessaging.instance
          .unsubscribeFromTopic(id);
    }

    await prefs.remove(_storageKey);
  }
}