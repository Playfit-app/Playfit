import 'package:flutter/material.dart';

class Landmark extends StatelessWidget {
  final String image;
  final Offset scale;
  final int difficulty;

  const Landmark({
    super.key,
    required this.image,
    required this.scale,
    required this.difficulty,
  });

  Widget _easyDifficultyPosition() {
    return Positioned(
      left: 220 * scale.dx,
      bottom: -0.2 * 80 * scale.dy + 340 * scale.dy,
      child: Transform.rotate(
        angle: 0,
        child: SizedBox(
          height: 150 * scale.dy,
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _mediumDifficultyPosition() {
    return Positioned(
      left: 30 * scale.dx,
      bottom: -0.2 * 80 * scale.dy + 400 * scale.dy,
      child: Transform.rotate(
        angle: 0,
        child: SizedBox(
          height: 150 * scale.dy,
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  Widget _hardDifficultyPosition() {
    return Positioned(
      left: 230 * scale.dx,
      bottom: -0.2 * 80 * scale.dy + 490 * scale.dy,
      child: Transform.rotate(
        angle: 0,
        child: SizedBox(
          height: 150 * scale.dy,
          child: Image.asset(
            image,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return difficulty == 1
        ? _easyDifficultyPosition()
        : difficulty == 2
            ? _mediumDifficultyPosition()
            : _hardDifficultyPosition();
  }
}
