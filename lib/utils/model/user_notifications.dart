
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.createdAt,
    required this.read,
  });

  /// Create from Firestore document data (uses Timestamp)
  factory AppNotification.fromMap(Map<String, dynamic> data, String id) {
    return AppNotification(
      id: id,
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'] ?? false,
    );
  }




  /// Create from a JSON map (used for local storage).
  /// Accepts createdAt as ISO string or epoch milliseconds.
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    DateTime parsedCreatedAt;

    if (json['createdAt'] == null) {
      parsedCreatedAt = DateTime.now();
    } else if (json['createdAt'] is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);
    } else if (json['createdAt'] is String) {
      // Expect ISO 8601 string
      try {
        parsedCreatedAt = DateTime.parse(json['createdAt'] as String);
      } catch (_) {
        parsedCreatedAt = DateTime.now();
      }
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return AppNotification(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      createdAt: parsedCreatedAt,
      read: json['read'] == true,
    );
  }

  /// Convert to JSON map for local storage.
  /// createdAt is saved as ISO string.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'read': read,
    };
  }




  AppNotification copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }



  bool get isExpired {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    return createdAt.isBefore(twentyFourHoursAgo);
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  IconData get icon {
    switch (type) {
      case 'tutorial_video':
        return Icons.video_library;
      case 'package_announcement':
        return Icons.airplane_ticket;
      case 'community_service':
        return Icons.people;
      case 'timing_update':
        return Icons.access_time;
      case 'super_admin_general_announcements':
        return Icons.announcement;
      case 'request_update_timings':
        return Icons.update;
      case 'user_wallet_update':
        return Icons.account_balance_wallet;
      case 'timing_notification':
        return Icons.notifications_active;
      case 'hadiya_notification':
        return Icons.attach_money;
      case 'bayan_notification':
        return Icons.record_voice_over;
      case 'live_stream':
        return Icons.live_tv;
      default:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case 'tutorial_video':
        return Colors.blue;
      case 'package_announcement':
        return Colors.green;
      case 'community_service':
        return Colors.orange;
      case 'timing_update':
        return Colors.purple;
      case 'super_admin_general_announcements':
        return Colors.red;
      case 'request_update_timings':
        return Colors.teal;
      case 'user_wallet_update':
        return Colors.amber;
      case 'timing_notification':
        return Colors.deepPurple;
      case 'hadiya_notification':
        return Colors.lightGreen;
      case 'bayan_notification':
        return Colors.brown;
      case 'live_stream':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
