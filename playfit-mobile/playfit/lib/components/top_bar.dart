import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:badges/badges.dart' as badges;

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     Icon(Icons.favorite, color: Color.fromARGB(255, 231, 29, 54)),
        //     Icon(Icons.favorite, color: Color.fromARGB(255, 231, 29, 54)),
        //     Icon(Icons.heart_broken, color: Color.fromARGB(255, 186, 26, 26)),
        //   ],
        // ),
        badges.Badge(
          position: badges.BadgePosition.bottomEnd(),
          badgeContent: const Text(
            '1',
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
