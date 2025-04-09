import 'dart:ui' as ui;
import "package:flutter/material.dart";

class Decorations {
  final Map<String, ui.Image> images;
  final double nbHills;
  final Offset scale;
  final double screenHeight;
  final double hillHeight;
  final bool transition;
  List<Map<String, dynamic>> decorations = [];

  Decorations({
    required this.images,
    required this.nbHills,
    required this.scale,
    required this.screenHeight,
    required this.hillHeight,
    required this.transition,
  }) {
    if (this.transition) {
      if (nbHills == 3) {
        _createEasyCityDecorations();
      } else if (nbHills == 4) {
        _createMediumCityDecorations();
      } else {
        _createHardCityDecorations();
      }
    } else {
      if (nbHills == 3) {
        _createEasyTransitionDecorations();
      } else if (nbHills == 4) {
        _createMediumTransitionDecorations();
      } else {
        _createMediumTransitionDecorations();
      }
    }
  }

  void _createEasyCityDecorations() {
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

  void _createMediumCityDecorations() {
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

  void _createHardCityDecorations() {
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

  void _createEasyTransitionDecorations() {
    decorations = [
      {
        "image": images["tree"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": screenHeight - hillHeight / 3.1,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 130 * scale.dx,
          "y": screenHeight - hillHeight / 2.7,
        },
        "rotationZ": 0.0,
      },
    ];

    if (nbHills == 3) {
      decorations.add({
        "image": images["tree"]!,
        "position": {
          "x": 210 * scale.dx,
          "y": screenHeight - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      });
      decorations.add({
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.dx,
          "y": screenHeight - hillHeight / 1.3,
        },
        "rotationZ": 0.0,
      });
    }
  }

  void _createMediumTransitionDecorations() {
    _createEasyTransitionDecorations();

    decorations.addAll([
      {
        "image": images["tree"]!,
        "position": {
          "x": 280 * scale.dx,
          "y": screenHeight - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 320 * scale.dx,
          "y": screenHeight - hillHeight / 1.15,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 80 * scale.dx,
          "y": screenHeight - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 40 * scale.dx,
          "y": screenHeight - hillHeight / 1.35,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.dx,
          "y": screenHeight - hillHeight / 1.35,
        },
        "rotationZ": 0.0,
      },
    ]);
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
