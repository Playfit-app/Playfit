import 'dart:ui' as ui;
import "package:flutter/material.dart";

class Decorations {
  final Map<String, ui.Image> images;
  final double nbHills;
  final Size screenSize;
  final bool transition;
  List<Map<String, dynamic>> decorations = [];

  Decorations({
    required this.images,
    required this.nbHills,
    required this.screenSize,
    required this.transition,
  }) {
    Size scale = Size(
      screenSize.width / 411,
      screenSize.height / 798,
    );
    if (this.transition) {
      if (nbHills == 3) {
        _createEasyCityDecorations(scale);
      } else if (nbHills == 4) {
        _createMediumCityDecorations(scale);
      } else {
        _createHardCityDecorations(scale);
      }
    } else {
      if (nbHills == 3) {
        _createEasyTransitionDecorations(scale);
      } else if (nbHills == 4) {
        _createMediumTransitionDecorations(scale);
      } else {
        _createMediumTransitionDecorations(scale);
      }
    }
  }

  void _createEasyCityDecorations(Size scale) {
    double hillHeight = screenSize.height / 2;

    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.width,
          "y": screenSize.height - hillHeight / 3,
        },
        "rotationZ": -0.6,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.width,
          "y": screenSize.height - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 320 * scale.width,
          "y": screenSize.height - hillHeight / 1.9,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.width,
          "y": screenSize.height - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createMediumCityDecorations(Size scale) {
    double hillHeight = screenSize.height / 2;

    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.width,
          "y": screenSize.height - hillHeight / 3,
        },
        "rotationZ": -0.6,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.width,
          "y": screenSize.height - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.width,
          "y": screenSize.height - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 300 * scale.width,
          "y": screenSize.height - hillHeight / 1.15,
        },
        "rotationZ": 0.1,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 140 * scale.width,
          "y": screenSize.height - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.width,
          "y": screenSize.height - hillHeight / 1.05,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createHardCityDecorations(Size scale) {
    double hillHeight = screenSize.height / 2;

    decorations = [
      {
        "image": images["building"]!,
        "position": {
          "x": 100 * scale.width,
          "y": screenSize.height - hillHeight / 3,
        },
        "rotationZ": -0.45,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 50 * scale.width,
          "y": screenSize.height - hillHeight / 4,
        },
        "rotationZ": -0.7,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.width,
          "y": screenSize.height - hillHeight / 1.5,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 320 * scale.width,
          "y": screenSize.height - hillHeight / 1.15,
        },
        "rotationZ": 0.1,
      },
      {
        "image": images["building"]!,
        "position": {
          "x": 130 * scale.width,
          "y": screenSize.height - hillHeight / 0.95,
        },
        "rotationZ": -0.5,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 140 * scale.width,
          "y": screenSize.height - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.width,
          "y": screenSize.height - hillHeight / 1.05,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 40 * scale.width,
          "y": screenSize.height - hillHeight / 1.02,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createEasyTransitionDecorations(Size scale) {
    double hillHeight = screenSize.height / 2;

    decorations = [
      {
        "image": images["tree"]!,
        "position": {
          "x": 100 * scale.width,
          "y": screenSize.height - hillHeight / 3.1,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 130 * scale.width,
          "y": screenSize.height - hillHeight / 2.7,
        },
        "rotationZ": 0.0,
      },
    ];

    if (nbHills == 3) {
      decorations.add({
        "image": images["tree"]!,
        "position": {
          "x": 210 * scale.width,
          "y": screenSize.height - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      });
      decorations.add({
        "image": images["tree"]!,
        "position": {
          "x": 180 * scale.width,
          "y": screenSize.height - hillHeight / 1.3,
        },
        "rotationZ": 0.0,
      });
    }
  }

  void _createMediumTransitionDecorations(Size scale) {
    double hillHeight = screenSize.height / 2;
    _createEasyTransitionDecorations(scale);

    decorations.addAll([
      {
        "image": images["tree"]!,
        "position": {
          "x": 280 * scale.width,
          "y": screenSize.height - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 320 * scale.width,
          "y": screenSize.height - hillHeight / 1.15,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 80 * scale.width,
          "y": screenSize.height - hillHeight / 1.2,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 40 * scale.width,
          "y": screenSize.height - hillHeight / 1.35,
        },
        "rotationZ": 0.0,
      },
      {
        "image": images["tree"]!,
        "position": {
          "x": 120 * scale.width,
          "y": screenSize.height - hillHeight / 1.35,
        },
        "rotationZ": 0.0,
      },
    ]);
  }

  void render(Canvas canvas, Size size) {
    for (final decoration in decorations) {
      Size scale = Size(
        size.width / 411,
        size.height / 798,
      );
      ui.Image image = decoration["image"];
      Map<String, double> position = decoration["position"];
      double rotationZ = decoration["rotationZ"];
      double maxHeight = 100 * scale.width;
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
