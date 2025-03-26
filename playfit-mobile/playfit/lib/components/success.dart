import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  final String image;
  final bool completed;
  final VoidCallback? onTap;

  const Success({
    super.key,
    required this.image,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: completed || onTap != null ? onTap : null,
      child: Opacity(
        opacity: completed ? 1.0 : 0.4,
        child: Container(
          height: MediaQuery.of(context).size.width * 0.17,
          width: MediaQuery.of(context).size.width * 0.17,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: completed ? Colors.black : Colors.grey,
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
