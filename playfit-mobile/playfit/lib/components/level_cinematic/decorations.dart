import "package:flutter/material.dart";

class Decorations extends StatelessWidget {
  final Map<String, String> decorationImages;
  final double nbHills;
  final Offset scale;
  List<Map<String, dynamic>> decorations = [];

  Decorations({
    super.key,
    required this.decorationImages,
    required this.nbHills,
    required this.scale,
  }) {
    if (nbHills == 3) {
      _createEasyDecorations();
    } else if (nbHills == 4) {
      _createMediumDecorations();
    } else {
      _createHardDecorations();
    }
  }

  double getYPosition(double position) {
    double y = 0.0;

    y = position == 0 ? position - 0.2 : position - 0.8;
    return y * 80 * scale.dy + 190 * scale.dy;
  }

  void _createEasyDecorations() {
    decorations = [
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 180 * scale.dy,
        },
        "rotationZ": -0.45,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 145 * scale.dy,
        },
        "rotationZ": -0.7,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 320 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 220 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 120 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 270 * scale.dy,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createMediumDecorations() {
    decorations = [
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 180 * scale.dy,
        },
        "rotationZ": -0.45,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 145 * scale.dy,
        },
        "rotationZ": -0.7,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 40 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 260 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 300 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 350 * scale.dy,
        },
        "rotationZ": 0.1,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 140 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 410 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 180 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 390 * scale.dy,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  void _createHardDecorations() {
    decorations = [
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 100 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 180 * scale.dy,
        },
        "rotationZ": -0.45,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 50 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 145 * scale.dy,
        },
        "rotationZ": -0.7,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 40 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 260 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 300 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 350 * scale.dy,
        },
        "rotationZ": 0.1,
      },
      {
        "image": decorationImages["building"]!,
        "position": {
          "x": 130 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 470 * scale.dy,
        },
        "rotationZ": -0.4,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 140 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 410 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 180 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 390 * scale.dy,
        },
        "rotationZ": 0.0,
      },
      {
        "image": decorationImages["tree"]!,
        "position": {
          "x": 40 * scale.dx,
          "y": -0.2 * 80 * scale.dy + 420 * scale.dy,
        },
        "rotationZ": 0.0,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (final decoration in decorations)
          Positioned(
            left: decoration["position"]["x"],
            bottom: decoration["position"]["y"],
            child: Transform.rotate(
              angle: decoration["rotationZ"],
              child: SizedBox(
                height: 100 * scale.dy,
                child: Image.asset(
                  decoration["image"],
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
