import 'package:flutter/material.dart';

class Checkpoint {
  final Offset position;
  final Size scale;
  final int id;

  Checkpoint({
    required this.position,
    required this.scale,
    required this.id,
  });

  void render(
    Canvas canvas,
    Paint dropShadowPaint,
    Paint checkpointPaint,
    Paint innerShadowPaint,
  ) {
    // Draw drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: position.translate(0, 8),
        width: 47 * scale.width,
        height: 29 * scale.height,
      ),
      dropShadowPaint,
    );

    // Draw inner shadow effect
    canvas.drawOval(
      Rect.fromCenter(
        center: position.translate(0, 4),
        width: 47 * scale.width,
        height: 29 * scale.height,
      ),
      innerShadowPaint,
    );

    // Draw main elipse
    canvas.drawOval(
      Rect.fromCenter(
        center: position,
        width: 47 * scale.width,
        height: 29 * scale.height,
      ),
      checkpointPaint,
    );
  }
}
