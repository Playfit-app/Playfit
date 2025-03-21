import 'package:flutter/material.dart';

class Checkpoint {
  final Offset position;
  final int id;

  Checkpoint({
    required this.position,
    required this.id,
  });

  void render(
    Canvas canvas,
    Offset scale,
    Paint dropShadowPaint,
    Paint checkpointPaint,
    Paint innerShadowPaint,
  ) {
    // Draw drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: position.translate(0, 8 * scale.dy),
        width: 47 * scale.dx,
        height: 29 * scale.dy,
      ),
      dropShadowPaint,
    );

    // Draw inner shadow effect
    canvas.drawOval(
      Rect.fromCenter(
        center: position.translate(0, 4 * scale.dy),
        width: 47 * scale.dx,
        height: 29 * scale.dy,
      ),
      innerShadowPaint,
    );

    // Draw main elipse
    canvas.drawOval(
      Rect.fromCenter(
        center: position,
        width: 47 * scale.dx,
        height: 29 * scale.dy,
      ),
      checkpointPaint,
    );
  }
}
