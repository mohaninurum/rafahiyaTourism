import 'package:flutter/material.dart';

class Announcement {
  final String id;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? imageUrl;
  final String time;
  final bool highlight;

  Announcement({
    required this.id,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.time,
    this.highlight = false,
  });
}
