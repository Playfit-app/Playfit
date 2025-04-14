import 'package:flutter/material.dart';

class DottedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double dotSize;
  final double spacing;

  const DottedLine({
    super.key,
    required this.height,
    this.color = Colors.blueAccent,
    this.dotSize = 4,
    this.spacing = 6,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(2, height),
      painter: _DottedLinePainter(
        color: color,
        dotSize: dotSize,
        spacing: spacing,
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double spacing;

  _DottedLinePainter({
    required this.color,
    required this.dotSize,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
  final paint = Paint()
    ..color = color
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.square;

  double y = 0;
  while (y < size.height) {
    canvas.drawLine(
      Offset(size.width / 2, y),
      Offset(size.width / 2, y + dotSize),
      paint,
    );
    y += dotSize + spacing;
  }
}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
