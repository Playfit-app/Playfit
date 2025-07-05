import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/providers/notification_provider.dart';

// I think the file is useless, as it is not used anywhere in the app.
class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(t.notifications.title),
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
