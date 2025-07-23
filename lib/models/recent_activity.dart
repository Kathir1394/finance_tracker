import 'package:flutter/material.dart';

enum ActivityType { transaction, investment, goal }

class RecentActivity {
  final String id;
  final String title;
  final String subtitle;
  final double? amount;
  final DateTime date;
  final ActivityType type;
  final IconData icon;
  final Color iconColor;

  RecentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    this.amount,
    required this.date,
    required this.type,
    required this.icon,
    required this.iconColor,
  });
}