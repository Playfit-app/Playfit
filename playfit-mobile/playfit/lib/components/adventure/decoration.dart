import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Decoration {
  final ui.Image image;
  final Offset position;
  final Size size;

  Decoration({
    required this.image,
    required this.position,
    required this.size,
  });

  void render(Canvas canvas) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height),
      Paint(),
    );
  }
}
