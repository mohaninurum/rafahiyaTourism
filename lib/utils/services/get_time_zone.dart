
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetTimeZone {
  static Future<String> setupTimezone() async {
    final timezoneInfo = await FlutterTimezone.getLocalTimezone();
    String currentTimeZone = timezoneInfo.identifier;
    print("Current timezone: $currentTimeZone");
    if (currentTimeZone == "Asia/Calcutta") {
      currentTimeZone = "Asia/Kolkata";
    }
    return currentTimeZone;
  }



  static  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> checkOrCreateTimeZone(bool isLogin,String topic) async {
    String? userId = await getUserId();
    final userRef =
    FirebaseFirestore.instance.collection('users').doc(userId);

    final userDoc = await userRef.get();
    if (!userDoc.exists) return null;

    final data = userDoc.data();
    String? finalTimeZone;
    if (data != null && data['timeZone'] != null) {
      await userRef.update({'timeZone': topic});
      // finalTimeZone = data['timeZone'];
      //
      // if (finalTimeZone == "Asia/Calcutta") {
      //   finalTimeZone = "Asia/Kolkata";
      //   await userRef.update({'timeZone': finalTimeZone});
      // }
    } else {
      // String deviceTimeZone = await setupTimezone();
      await userRef.set({
        'timeZone': topic,
      }, SetOptions(merge: true));

      finalTimeZone = topic;
    }
    // if(isLogin==false){
    //   await FirebaseMessaging.instance.subscribeToTopic(topic);
    // }else if (finalTimeZone != null) {
    //   String topic = finalTimeZone.replaceAll('/', '_');
    //   await FirebaseMessaging.instance.subscribeToTopic(topic);
    // }

    return finalTimeZone;
  }



}
