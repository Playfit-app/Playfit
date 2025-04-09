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
            Icon(Icons.favorite, color: Color.fromARGB(255, 231, 29, 54)),
            Icon(Icons.favorite, color: Color.fromARGB(255, 231, 29, 54)),
            Icon(Icons.heart_broken, color: Color.fromARGB(255, 186, 26, 26)),
          ],
        ),
        Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(Icons.local_fire_department,
                  color: Color.fromARGB(255, 255, 122, 0), size: 28),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                backgroundColor: Color.fromARGB(255, 186, 26, 26),
                radius: 8,
                child: Text('1',
                    style: TextStyle(fontSize: 10, color: Colors.white)),
              ),
            )
          ],
        ),
      ],
    );
  }
}
