import 'dart:ui' as ui;
import "package:flutter/material.dart";

class Decorations {
  final Map<String, ui.Image> images;
  final double nbHills;
  final Offset scale;
  final double screenHeight;
  final double hillHeight;
  List<Map<String, dynamic>> decorations = [];

  Decorations({
    required this.images,
    required this.nbHills,
    required this.scale,
    required this.screenHeight,
    required this.hillHeight,
  }) {
    if (nbHills == 3) {
      _createEasyDecorations();
    } else if (nbHills == 4) {
      _createMediumDecorations();
    } else {
      _createHardDecorations();
    }
  }

  void _createEasyDecorations() {
    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": screenHeight - hillHeight / 3,
        },
        "rotationZ": -0.6,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": screenHeight - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 320 * scale.dx,
          "y": screenHeight - hillHeight / 1.9,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.dx,
          "y": screenHeight - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createMediumDecorations() {
    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": screenHeight - hillHeight / 3,
        },
        "rotationZ": -0.6,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": screenHeight - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.dx,
          "y": screenHeight - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 300 * scale.dx,
          "y": screenHeight - hillHeight / 1.15,
        },
        "rotationZ": 0.1,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 140 * scale.dx,
          "y": screenHeight - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.dx,
          "y": screenHeight - hillHeight / 1.05,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createHardDecorations() {
    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": screenHeight - hillHeight / 3,
        },
        "rotationZ": -0.45,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": screenHeight - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.dx,
          "y": screenHeight - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 320 * scale.dx,
          "y": screenHeight - hillHeight / 1.15,
        },
        "rotationZ": 0.1,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 130 * scale.dx,
          "y": screenHeight - hillHeight / 0.95,
        },
        "rotationZ": -0.5,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 140 * scale.dx,
          "y": screenHeight - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.dx,
          "y": screenHeight - hillHeight / 1.05,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 40 * scale.dx,
          "y": screenHeight - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void render(Canvas canvas, Size size) {
    for (final decoration in decorations) {
      ui.Image image = decoration["image"];
      Map<String, double> position = decoration["position"];
      double rotationZ = decoration["rotationZ"];
      double maxHeight = 100 * scale.dy;
      double aspectRatio = image.width / image.height.toDouble();
      double maxWidth = maxHeight * aspectRatio;

      canvas.save();

      canvas.translate(position["x"]!, position["y"]!);

      canvas.rotate(rotationZ);

      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(
          -maxWidth / 2,
          -maxHeight / 2,
          maxWidth,
          maxHeight,
        ),
        Paint(),
      );

      canvas.restore();
    }
  }
}
