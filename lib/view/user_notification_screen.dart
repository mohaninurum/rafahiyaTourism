import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/notification_list_provider.dart';
import '../services/notification_repo.dart';
import 'model/notification_model.dart';

class UserNotificationScreen extends StatefulWidget {
  final String currentUserId;

  UserNotificationScreen({required this.currentUserId, Key? key})
    : super(key: key);

  @override
  State<UserNotificationScreen> createState() => _UserNotificationScreenState();
}

class _UserNotificationScreenState extends State<UserNotificationScreen> {
  final NotificationRepo repo = NotificationRepo();

  @override
  void initState() {
    // Provider.of<NotificationListProvider>(context, listen: false).fetchNotificationsApi(userId: widget.currentUserId);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationListProvider>().fetchNotificationsApi(
        userId: widget.currentUserId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("notifications")),
      body: Consumer<NotificationListProvider>(
        builder: (context, value, child) {
          return value.isLoading
              ? Center(child: CircularProgressIndicator())
              : value.notificationResponse?.data.isEmpty == true
              ? Center(child: Text('No notifications yet.'))
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
              );
        },
      ),
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
}
