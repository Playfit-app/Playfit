import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            Icon(Icons.favorite, color: Colors.red),
            Icon(Icons.favorite_border, color: Colors.red),
          ],
        ),
        Stack(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 8,
                child: Text('1', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            )
          ],
        ),
      ],
    );
  }
}