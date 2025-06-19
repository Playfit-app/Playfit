import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:badges/badges.dart' as badges;

class TopBar extends StatefulWidget {
  final int currentStreak;

  const TopBar({super.key, required this.currentStreak,});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    // Build a top bar with a streak badge and a notification icon with a badge.
    // The streak badge shows the current streak count, and the notification icon
    // shows the number of unread notifications.
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        badges.Badge(
          position: badges.BadgePosition.bottomEnd(),
          badgeContent: Text(
            '${widget.currentStreak}',
            style: TextStyle(color: Colors.white),
          ),
          badgeStyle: const badges.BadgeStyle(
            badgeColor: Color.fromARGB(255, 186, 26, 26),
            padding: EdgeInsets.all(5),
          ),
          child: const Icon(
            Icons.local_fire_department,
            color: Color.fromARGB(255, 255, 122, 0),
            size: 32,
          ),
        ),
        Spacer(),
        // Notification icon with a badge showing the number of unread notifications.
        // The badge is shown only if there are unread notifications.
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            return badges.Badge(
              position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
              showBadge: notificationProvider.unreadCount > 0,
              badgeContent: Text(
                '${notificationProvider.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color.fromARGB(255, 186, 26, 26),
                padding: EdgeInsets.all(5),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.mail,
                  size: 32,
                  color: Color.fromARGB(255, 255, 122, 0),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
