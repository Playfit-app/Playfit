import 'dart:math';
import 'package:flutter/material.dart';

class Hill extends StatelessWidget {
  final int position;
  final Offset scale;
  final Map<String, String> decorationImages;

  const Hill({
    super.key,
    required this.position,
    required this.scale,
    required this.decorationImages,
  });

  double getBottomPosition() {
    double bottom = 0.0;

    bottom = position == 0 ? position - 0.2 : position - 0.8;
    return bottom * 80 * scale.dy;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: getBottomPosition(),
      left: 0,
      right: 0,
      child: Transform(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.rotationY(position % 2 == 0 ? 0 : pi),
        child: SizedBox(
          height: 250 * scale.dy,
          child: Image.asset(
            decorationImages["hill"]!,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
