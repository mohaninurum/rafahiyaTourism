class NotificationItem {
  final NotificationType type;
  final String title;
  final String description;
  final String time;
  bool isRead;

  NotificationItem({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
  });
}
enum NotificationType {
  adminRequest,
  salahAlert,
  globalAd,
}
