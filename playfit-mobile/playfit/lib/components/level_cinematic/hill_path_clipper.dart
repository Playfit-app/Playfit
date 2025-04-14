import 'package:flutter/material.dart';

abstract class _HillClipper extends CustomClipper<Path> {
  final double startY;
  final Offset scale;
  final double height;

  _HillClipper({
    required this.startY,
    required this.scale,
    required this.height,
  });
}

class HillPathClipper extends _HillClipper {
  HillPathClipper({
    required super.startY,
    required super.scale,
    required super.height,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, startY);
    path.cubicTo(
      size.width * 0.95,
      startY - height,
      size.width + 40,
      startY - 30,
      size.width + 30,
      startY - 30,
    );
    path.cubicTo(
      size.width * 0.9,
      startY + 50,
      size.width * 0.6,
      startY + 70,
      0,
      startY,
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class BackgroundHillPathClipper extends _HillClipper {
  BackgroundHillPathClipper({
    required super.startY,
    required super.scale,
    required super.height,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, startY + 10);
    path.cubicTo(
      size.width * 0.97,
      startY - height,
      size.width + 60,
      startY - 50,
      size.width + 50,
      startY - 30,
    );
    path.cubicTo(
      size.width * 0.92,
      startY + 70,
      size.width * 0.6,
      startY + 90,
      0,
      startY + 10,
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
