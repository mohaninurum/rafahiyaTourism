import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../utils/model/auth/auth_user_model.dart';

class SettingProvider with ChangeNotifier {
  AuthUserModel? _user;
  bool _isLoading = false;
  String? _error;

  // notification settings
  bool sahahUpdate = false;
  bool banyanAlerts = false;
  bool clockChangeNotification = false;

  AuthUserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ---------------- FETCH SETTINGS ----------------
  Future<void> fetchSetting() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final uid = _userId;
      if (uid == null) {
        _error = 'No user logged in';
        return;
      }

      // fetch user profile
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _user = AuthUserModel.fromMap(userDoc.data()!, uid);
      }

      // fetch notification settings
      final settingDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications_setting')
          .doc('settings')
          .get();

      if (settingDoc.exists) {
        final data = settingDoc.data()!;
        print("Setting Data ::$data");
        sahahUpdate = data['sahahUpdate'] ?? false;
        banyanAlerts = data['banyanAlerts'] ?? false;
        clockChangeNotification =
            data['clock_change_notification'] ?? false;
      }
    } catch (e) {
      _error = 'Failed to fetch settings: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- UPDATE NOTIFICATION ----------------
  Future<void> updateNotificationSetting({
    required String key,
    required bool value,
  }) async {
    try {
      final uid = _userId;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications_setting')
          .doc('settings')
          .set(
        {key: value},
        SetOptions(merge: true),
      );

      // local update
      if (key == 'sahahUpdate') sahahUpdate = value;
      if (key == 'banyanAlerts') banyanAlerts = value;
      if (key == 'clock_change_notification') {
        clockChangeNotification = value;
      }
      print("update..............");

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update notification: $e';
      notifyListeners();
    }
  }
}












// sendTimingUpdateNotification (created) exports.sendTimingUpdateNotification = onDocumentCreated({ document: "mosques/{mosqueId}/{timingType}/{timingId}", secrets: [ONESIGNAL_APP_ID, ONESIGNAL_API_KEY], }, async (event) => { const timingData = event.data.data(); const { app_id, api_key } = getSecrets(); if (!timingData || !app_id || !api_key) { logger.error("Missing data/credentials"); return; } const imamId = timingData.imamId; const namazName = timingData.namazName || "Namaz"; if (!imamId) { logger.error("No imamId found"); return; } try { const firestore = admin.firestore(); const userSettingsSnap = await firestore.collection("user_mosque_settings").get(); const matchedUserIds = []; userSettingsSnap.forEach((doc) => { const data = doc.data(); let mosqueSelections = data.mosqueSelections || []; if (!Array.isArray(mosqueSelections) && typeof mosqueSelections === "object") { mosqueSelections = Object.values(mosqueSelections); } if (Array.isArray(mosqueSelections)) { const match = mosqueSelections.some((sel) => sel.uid === imamId); if (match) matchedUserIds.push(doc.id); } }); if (matchedUserIds.length === 0) { logger.log("No users found linked with imamId:", imamId); return; } const playerIds = []; for (const userId of matchedUserIds) { const userDoc = await firestore.collection("users").doc(userId).get(); if (userDoc.exists && userDoc.data().playerId) playerIds.push(userDoc.data().playerId); } if (playerIds.length === 0) { logger.log("No playerIds found for users of imamId:", imamId); return; } const payload = { app_id, include_player_ids: playerIds, headings: { en: Update in ${namazName} Timing }, contents: { en: Your selected mosque has updated ${namazName} timing. }, data: { type: "timing_update", imamId, namazName, mosqueId: event.params.mosqueId, timingType: event.params.timingType, timingId: event.params.timingId }, }; const response = await axios.post("https://onesignal.com/api/v1/notifications", payload, { headers: { Authorization: Basic ${api_key}, "Content-Type": "application/json" }, }); logger.log(Notification sent to ${playerIds.length} users, response.data); // store notification (broadcast to matched users) await storeNotification({ title: Update in ${namazName} Timing, message: Your selected mosque has updated ${namazName} timing., type: "timing_update", senderRole: "subadmin", receiverRole: "user", receiverId: matchedUserIds, extraData: { imamId, namazName, mosqueId: event.params.mosqueId, timingType: event.params.timingType, timingId: event.params.timingId } }); } catch (err) { logger.error("Error sending timing update:", err.response?.data || err.message || err); } isme specific use ka notification enable and disable karna hai kese
