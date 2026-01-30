

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/notification_list_provider.dart';
import '../services/notification_repo.dart';
import 'model/notification_model.dart';


class UserNotificationScreen extends StatefulWidget {


  UserNotificationScreen({ Key? key}) : super(key: key);

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  final NotificationRepo repo = NotificationRepo();


  @override
  void initState() {
    Provider.of<NotificationListProvider>(context, listen: false).fetchNotificationsApi();
    super.initState();
  }

  getUserID(){
    // FirebaseAuth.instance.currentUser!.uid,
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("notifications"),actions: [
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        //   child: ElevatedButton(onPressed: () {
        //     showDeleteNotificationConfirmDialog(context);
        //   }, child: Text("All Clear")),
        // )
      ],),
      body: Consumer<NotificationListProvider>(builder: (context, value, child) {
        return value.isLoading
            ? value.notificationResponse?.data.isEmpty==true ?Center(child: Text('No notifications yet.'))
            : ListView.builder(
        itemCount: value.notificationResponse?.data.length,
        itemBuilder: (context, i) {
          final n = value.notificationResponse?.data[i];
          return ListTile(
            title: Text("${n?.title}"),
            subtitle: Text("${n?.body}"),
            trailing: Text("${n?.time}"),
            onTap: () {},
          );
        },
      ):Center(child: CircularProgressIndicator());
      },)
      // FutureBuilder<List<AppNotification>>(
      //   future: repo.fetchNotificationsForCurrentUser(
      //     // role: 'user',
      //     currentUserId: widget.currentUserId,
      //   ),
      //   builder: (context, snap) {
      //     if (snap.connectionState == ConnectionState.waiting) {
      //       return Center(child: CircularProgressIndicator());
      //     }
      //     if (!snap.hasData || snap.data!.isEmpty) {
      //       return Center(child: Text('No notifications yet.'));
      //     }
      //
      //     final list = snap.data!;
      //
      //     return ListView.builder(
      //       itemCount: list.length,
      //       itemBuilder: (context, i) {
      //         final n = list[i];
      //         final ts = n.timestamp?.toDate();
      //
      //         return ListTile(
      //           title: Text(n.title),
      //           subtitle: Text(n.message),
      //           trailing: ts != null
      //               ? Text("${ts.hour}:${ts.minute.toString().padLeft(2, '0')}")
      //               : null,
      //           onTap: () {},
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }

  void showDeleteNotificationConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Delete Notification',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this notification? '
                'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // cancel
                // Provider.of<NotificationListProvider>(context, listen: false).deleteAllNotification();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }



}
