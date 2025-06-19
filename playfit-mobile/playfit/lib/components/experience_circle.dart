import 'package:flutter/material.dart';
import 'dart:math';

/// A custom painter that draws a circular progress indicator representing experience.
///
/// The [ExperienceCirclePainter] draws a transparent background circle and a colored arc
/// indicating the progress. The progress is a value between 0.0 and 1.0, where 1.0 means
/// the circle is fully completed.
class ExperienceCirclePainter extends CustomPainter {
  final double progress;

  ExperienceCirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = const Color.fromARGB(255, 115, 145, 253)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = (size.width - 4) / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    double sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ExperienceCircle extends StatelessWidget {
  final double currentXP;
  final double requiredXP;
  final Widget child;

  const ExperienceCircle({
    super.key,
    required this.currentXP,
    required this.requiredXP,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (currentXP / requiredXP).clamp(0.0, 1.0);
    double size = MediaQuery.of(context).size.width * 0.17;

    return CustomPaint(
      painter: ExperienceCirclePainter(progress),
      size: Size.square(size),
      child: child,
    );
  }
}
