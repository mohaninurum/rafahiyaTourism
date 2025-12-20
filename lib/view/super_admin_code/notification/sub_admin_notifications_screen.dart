// subadmin_notification_screen.dart
import 'package:flutter/material.dart';
import '../../../services/notification_repo.dart';
import '../../model/notification_model.dart';

class SubAdminNotificationScreen extends StatelessWidget {
  final String currentSubAdminId;
  final NotificationRepo repo = NotificationRepo();

  SubAdminNotificationScreen({
    required this.currentSubAdminId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("HelloShakiSub $currentSubAdminId");

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          "SubAdmin Notifications",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),

      body: StreamBuilder<List<AppNotification>>(
        stream: repo.streamNotifications(
          receiverRole: 'subadmin',
          receiverId: currentSubAdminId,
        ),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final list = snap.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final n = list[i];
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    child: Icon(Icons.notifications, color: Colors.orange),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      n.message,
                      style: TextStyle(color: Colors.black87, height: 1.3),
                    ),
                  ),
                  onTap: () {
                    // Notification details
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}