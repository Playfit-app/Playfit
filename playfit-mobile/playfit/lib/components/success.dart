import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  final String image;
  final bool completed;

  const Success({
    super.key,
    required this.image,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 71,
      width: 71,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: completed ? Colors.black : Colors.grey,
          width: 1.5,
        ),
      ),
      child: ClipOval(child: Image.asset(image)),
    );
  }
}
