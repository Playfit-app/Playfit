import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/providers/notification_provider.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.notifications.title),
        actions: [
          TextButton(
            onPressed: () async {
              provider.markAllAsRead();
            },
            child: Text(
              t.notifications.read_all,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: provider.notifications.length,
        itemBuilder: (context, index) {
          final n = provider.notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(n['title'] ?? t.notifications.no_title),
            subtitle: Text(n['body'] ?? t.notifications.no_body),
            trailing: Text(n['timestamp'] ?? ""),
          );
        },
      ),
    );
  }
}
