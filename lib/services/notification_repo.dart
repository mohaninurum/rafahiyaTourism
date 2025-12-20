// notification_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../view/model/notification_model.dart';

class NotificationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'notifications';

  Stream<List<AppNotification>> streamNotifications({
    String? receiverRole,
    String? receiverId,
    int limit = 50,
  }) {
    print("Nitifications.........");
    Query query = _firestore.collection(collection);
    print("Notifications List${query}");
    if (receiverRole != null) {
      query = query.where('receiverRole', isEqualTo: receiverRole);
    }

    if (receiverId != null) {
      query = query.where('receiverId', isEqualTo: receiverId); // works now
    }

    query = query.orderBy('timestamp', descending: true).limit(limit);

    return query.snapshots().map(
            (snap) => snap.docs.map((d) => AppNotification.fromDoc(d)).toList()
    );
  }




  // Stream<List<AppNotification>> streamNotifications({
  //   required String receiverRole,
  //   required String receiverId,
  //   int limit = 50,
  // }) {
  //   Query query = _firestore.collection(collection);
  //
  //   // Fetch notifications for this role/user
  //   query = query.where('receiverRole', isEqualTo: receiverRole)
  //       .where('receiverId', isEqualTo: receiverId);
  //
  //   // Also fetch broadcast notifications (receiverRole == null)
  //   Query broadcastQuery = _firestore.collection(collection)
  //       .where('receiverRole', isNull: true);
  //
  //   // Merge the two streams
  //   return Rx.combineLatest2(
  //     query.orderBy('timestamp', descending: true).limit(limit).snapshots(),
  //     broadcastQuery.orderBy('timestamp', descending: true).limit(limit).snapshots(),
  //         (QuerySnapshot targetedSnap, QuerySnapshot broadcastSnap) {
  //       final list = [
  //         ...targetedSnap.docs.map((d) => AppNotification.fromDoc(d)),
  //         ...broadcastSnap.docs.map((d) => AppNotification.fromDoc(d)),
  //       ];
  //
  //       // Sort combined list by timestamp descending
  //       list.sort((a, b) => b.timestamp.compareTo(a!.timestamp!);
  //       return list.take(limit).toList();
  //     },
  //   );
  // }



// Fallback: fetch notifications for role (including broadcasts & user-targeted)
  Future<List<AppNotification>> fetchNotificationsForCurrentUser({
    required String currentUserId,
    int limit = 50,
  }) async {
    final colRef = _firestore.collection(collection);
     print("Notifications List${colRef}");
    // Query: notifications where receiverId array contains currentUserId
    final querySnap = await colRef
        .where('receiverId', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    print("Matched notifications count: ${querySnap.docs.length}");

    // Convert each document to AppNotification
    final notifications = querySnap.docs
        .map((doc) => AppNotification.fromDoc(doc))
        .toList();

    // Optional: print for debugging
    for (var n in notifications) {
      print("Notification: ${n.title} | ${n.message} | ${n.timestamp}");
    }

    return notifications;
  }



  Future<void> saveLocalNotification(AppNotification n) async {
    final colRef = _firestore.collection(collection);
    // If you want duplicates avoided, you could use a deterministic id. Here we simply add.
    await colRef.add(n.toMap());
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    final ref = _firestore.collection(collection).doc(notificationId);
    await ref.set({
      'readBy': { userId: true }
    }, SetOptions(merge: true));
  }
}
