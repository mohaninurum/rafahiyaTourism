import 'package:flutter/material.dart';

import '../../../services/notification_repo.dart';
import '../../model/notification_model.dart';

class SuperAdminNotificationScreen extends StatelessWidget {
  final String currentSuperAdminId;
  final NotificationRepo repo = NotificationRepo();

  SuperAdminNotificationScreen({required this.currentSuperAdminId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Super Admin Notifications")),
      body: FutureBuilder<List<AppNotification>>(
        future: repo.fetchNotificationsForCurrentUser(
            // role: 'super_admin',
            currentUserId: currentSuperAdminId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          final list = snap.data ?? [];
          if (list.isEmpty) return Center(child: Text('No notifications yet.'));
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final n = list[i];
              return ListTile(
                title: Text(n.title),
                subtitle: Text(n.message),
                onTap: () {/* details */},
              );
            },
          );
        },
      ),
    );
  }
}
