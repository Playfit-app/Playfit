import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';

class Landmark {
  final ui.Image image;
  final Difficulty difficulty;
  final Size screenSize;
  late Offset position;

  Landmark({
    required this.image,
    required this.difficulty,
    required this.screenSize,
  }) {
    position = const Offset(0, 0);
    Size scale = Size(
      screenSize.width / 411,
      screenSize.height / 798,
    );

    if (difficulty == Difficulty.easy) {
      _easyDifficultyPosition(scale);
    } else if (difficulty == Difficulty.medium) {
      _mediumDifficultyPosition(scale);
    } else {
      _hardDifficultyPosition(scale);
    }
  }

  void _easyDifficultyPosition(Size scale) {
    double hillHeight = screenSize.height / 2;

    position = Offset(
      300 * scale.width,
      screenSize.height - hillHeight / 1.15,
    );
  }

  void _mediumDifficultyPosition(Size scale) {
    double hillHeight = screenSize.height / 2;

    position = Offset(
      80 * scale.width,
      screenSize.height - hillHeight,
    );
  }

  void _hardDifficultyPosition(Size scale) {
    double hillHeight = screenSize.height / 2;

    position = Offset(
      300 * scale.width,
      screenSize.height - hillHeight / 0.83,
    );
  }

  void render(Canvas canvas, Size size) {
    Size scale = Size(
      size.width / 411,
      size.height / 798,
    );
    double maxHeight = 150 * scale.height;
    double aspectRatio = image.width / image.height.toDouble();
    // double maxWidth = maxHeight * aspectRatio;
    // Max width is 150 * scale.dx or aspect ratio of the image
    double maxWidth = maxHeight * aspectRatio;
    if (maxWidth > 150 * scale.width) {
      maxWidth = 210 * scale.width;
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
