import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playfit/providers/notification_provider.dart';
import 'package:badges/badges.dart' as badges;

class TopBar extends StatefulWidget {
  final int currentStreak;
  final int? coins;
  final bool showCoins;

  const TopBar({
    super.key,
    required this.currentStreak,
    this.coins,
    this.showCoins = false,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    // In the shop we only show the coins pill; elsewhere we show streak + notifications.
    if (widget.showCoins && widget.coins != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildCoinsPill(),
        ],
      );
    }

    // Build a top bar with a streak badge and a notification icon with a badge.
    // The streak badge shows the current streak count, and the notification icon shows unread notifications.
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
        const Spacer(),
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

  Widget _buildCoinsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 248, 225),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color.fromARGB(255, 249, 200, 99),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: Color.fromARGB(255, 219, 176, 34),
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            '${widget.coins}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color.fromARGB(255, 113, 93, 52),
            ),
          ),
        ],
      ),
    );
  }
}
