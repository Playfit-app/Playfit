import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';

class Landmark {
  final ui.Image image;
  final Offset scale;
  final Difficulty difficulty;
  final double screenHeight;
  final double hillHeight;
  late Offset position;

  Landmark({
    required this.image,
    required this.scale,
    required this.difficulty,
    required this.screenHeight,
    required this.hillHeight,
  }) {
    position = const Offset(0, 0);

    if (difficulty == Difficulty.easy) {
      _easyDifficultyPosition();
    } else if (difficulty == Difficulty.medium) {
      _mediumDifficultyPosition();
    } else {
      _hardDifficultyPosition();
    }
  }

  void _easyDifficultyPosition() {
    position = Offset(
      300 * scale.dx,
      screenHeight - hillHeight / 1.15,
    );
  }

  void _mediumDifficultyPosition() {
    position = Offset(
      80 * scale.dx,
      screenHeight - hillHeight,
    );
  }

  void _hardDifficultyPosition() {
    position = Offset(
      300 * scale.dx,
      screenHeight - hillHeight / 0.83,
    );
  }

  void render(Canvas canvas, Size size) {
    double maxHeight = 150 * scale.dy;
    double aspectRatio = image.width / image.height.toDouble();
    // double maxWidth = maxHeight * aspectRatio;
    // Max width is 150 * scale.dx or aspect ratio of the image
    double maxWidth = maxHeight * aspectRatio;
    if (maxWidth > 150 * scale.dx) {
      maxWidth = 210 * scale.dx;
      maxHeight = maxWidth / aspectRatio;
    }

    canvas.save();
    canvas.translate(
      position.dx,
      position.dy,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(
        -image.width / 2,
        -image.height / 2,
        maxWidth,
        maxHeight,
      ),
      Paint(),
    );
    canvas.restore();
  }
}
