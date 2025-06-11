import 'package:flutter/material.dart';

class PostCardBottom extends StatelessWidget {
  const PostCardBottom({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.02,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9CA),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }
}
