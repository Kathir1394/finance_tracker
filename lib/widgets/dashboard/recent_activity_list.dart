import 'package:flutter/material.dart';
import '../../providers/providers.dart'; // Import the Activity model

class RecentActivityList extends StatelessWidget {
  final List<Activity> activities;
  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    // Replace with your actual list implementation
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: Icon(activity.icon),
            title: Text(activity.title),
            trailing: Text(activity.amount),
          );
        },
        childCount: activities.length,
      ),
    );
  }
}