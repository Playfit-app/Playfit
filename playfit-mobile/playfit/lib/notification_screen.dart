import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifications'),
          ),
          body: ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return ListTile(
                title: Text(notification['sender']),
                subtitle: Text(notification['notification_type']),
              );
            },
          ),
        );
      },
    );
  }
}
