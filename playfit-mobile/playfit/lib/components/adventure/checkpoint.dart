import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Checkpoint extends PositionComponent with TapCallbacks {
  final Vector2 checkpointPosition;
  final Function onTap;

  Checkpoint({required this.checkpointPosition, required this.onTap}) {
    size = Vector2(47, 29);
    position = checkpointPosition;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    // Drop shadow
    final dropShadowPaint = Paint()
      ..color = const Color.fromARGB(64, 0, 0, 0)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    // Main checkpoint
    final checkpointPaint = Paint()
      ..color = const Color.fromARGB(255, 160, 190, 223)
      ..style = PaintingStyle.fill;

    // Inner shadow
    final innerShadowPaint = Paint()..color = const Color.fromARGB(64, 0, 0, 0);

    // Draw drop shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 8),
        width: 47,
        height: 29,
      ),
      dropShadowPaint,
    );

    // // Draw inner shadow effect
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 4),
        width: 47,
        height: 29,
      ),
      innerShadowPaint,
    );

    // Draw main elipse
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(0, 0),
        width: 47,
        height: 29,
      ),
      checkpointPaint,
    );
  }

  @override
  bool containsPoint(Vector2 point) {
    // Convert point to local coordinates relative to the center of the checkpoint
    Vector2 localPoint = point - position;

    // Check if the point is inside the ellipse
    double dx = localPoint.x / (size.x / 2);
    double dy = localPoint.y / (size.y / 2);

    return (dx * dx + dy * dy) <= 1;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
  }
}
