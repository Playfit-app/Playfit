import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AdventurePage extends StatelessWidget {
  const AdventurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: GameWidget(
              game: AdventureGame(screenSize: MediaQuery.of(context).size),
            ),
          ),
        ),
        // White Gradient Overlay
        Positioned(
          top: -14,
          left: 0,
          right: 0,
          child: Container(
            height: 292,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.white,
                  Colors.white.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdventureGame extends FlameGame {
  final Size screenSize;
  late SpriteComponent _player;

  AdventureGame({required this.screenSize});
  final List<Vector2> _checkpoints = [
    Vector2(0, 0),
    Vector2(300, 100),
    Vector2(500, 220),
    Vector2(700, 300),
    Vector2(900, 400),
    Vector2(1100, 500),
    Vector2(1000, 600),
    Vector2(800, 700),
    Vector2(600, 800),
    Vector2(400, 900),
    Vector2(200, 1000),
    Vector2(0, 1100),
  ];
  int _currentCheckpoint = 1;

  @override
  Future<void> onLoad() async {
    // _player = SpriteComponent.fromImage(
    //   await images.load('character.png'),
    //   size: Vector2(410, 732),
    // );
    // add(_player);
  }

  void moveToNextCheckpoint() {
    if (_currentCheckpoint < _checkpoints.length - 1) {
      _currentCheckpoint++;
    }
  }

  void renderRoad(Canvas canvas) {
    final greyPaint = Paint()
      ..color = const Color.fromARGB(255, 129, 147, 167)
      ..strokeWidth = 50
      ..style = PaintingStyle.stroke;
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final greyPath = Path();
    final whitePath = Path();

    //M259.577 758
    //C251.577 635 -20.9231 668 33.0769 583
    //C87.0769 498 307.577 583 313.577 470
    //C319.577 357 15.5769 375.5 67.5769 258.5
    //C119.577 141.5 243.577 245.5 291.577 162.5
    //C339.577 79.5 171.077 24.5 171.077 0

    double offsetGrey = 22;
    greyPath.moveTo(259.577 + offsetGrey, 758);
    greyPath.cubicTo(251.577 + offsetGrey, 635, -20.9231 + offsetGrey, 668,
        33.0769 + offsetGrey, 583);
    greyPath.cubicTo(87.0769 + offsetGrey, 498, 307.577 + offsetGrey, 583,
        313.577 + offsetGrey, 470);
    greyPath.cubicTo(319.577 + offsetGrey, 357, 15.5769 + offsetGrey, 375.5,
        67.5769 + offsetGrey, 258.5);
    greyPath.cubicTo(119.577 + offsetGrey, 141.5, 243.577 + offsetGrey, 245.5,
        291.577 + offsetGrey, 162.5);
    greyPath.cubicTo(339.577 + offsetGrey, 79.5, 171.077 + offsetGrey, 24.5,
        171.077 + offsetGrey, 0);

    //M235.577 758
    //C227.577 635 -44.9231 668 9.07689 583
    //C63.0769 498 283.577 583 289.577 470
    //C295.577 357 -8.4231 375.5 43.5769 258.5
    //C95.5769 141.5 219.577 245.5 267.577 162.5
    //C315.577 79.5 147.077 24.5 147.077 0

    double offsetWhite = offsetGrey + 22;
    whitePath.moveTo(235.577 + offsetWhite, 758);
    whitePath.cubicTo(227.577 + offsetWhite, 635, -44.9231 + offsetWhite, 668,
        9.07689 + offsetWhite, 583);
    whitePath.cubicTo(63.0769 + offsetWhite, 498, 283.577 + offsetWhite, 583,
        289.577 + offsetWhite, 470);
    whitePath.cubicTo(295.577 + offsetWhite, 357, -8.4231 + offsetWhite, 375.5,
        43.5769 + offsetWhite, 258.5);
    whitePath.cubicTo(95.5769 + offsetWhite, 141.5, 219.577 + offsetWhite,
        245.5, 267.577 + offsetWhite, 162.5);
    whitePath.cubicTo(315.577 + offsetWhite, 79.5, 147.077 + offsetWhite, 24.5,
        147.077 + offsetWhite, 0);

    canvas.drawPath(greyPath, greyPaint);
    drawDashedPath(canvas, whitePath, whitePaint);
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        Path dashPath = pathMetric.extractPath(distance, distance + 10);
        canvas.drawPath(dashPath, paint);
        distance += 20;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final background = Paint()
      ..color = const Color.fromARGB(255, 197, 222, 250)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, screenSize.width, screenSize.height),
      background,
    );

    renderRoad(canvas);
  }
}
