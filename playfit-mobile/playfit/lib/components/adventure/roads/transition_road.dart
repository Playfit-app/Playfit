import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/roads/road.dart';
import 'package:playfit/components/adventure/checkpoint.dart';
import 'package:playfit/components/adventure/decoration.dart' as dec;

class TransitionRoad extends Road {
  final List<Path> paths = [];
  late double oldStartY;

  TransitionRoad({
    required super.startY,
    required super.scale,
    required super.decorationImages,
    required super.cityIndex,
  }) {
    oldStartY = startY;
    buildBrownPath();
    buildWhitePath();
    setCheckpoints(4);
    setDecorations();
  }

  @override
  void setDecorations() {
    final ui.Image treeImage = decorationImages['tree'];
    const Size treeSize = Size(79, 118);

    decorations = [
      dec.Decoration(
        image: treeImage,
        position: Offset(100 * scale.dx, startY + 225 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(70 * scale.dx, startY + 225 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(80 * scale.dx, startY + 240 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(80 * scale.dx, startY - 20 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(50 * scale.dx, startY - 20 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(60 * scale.dx, startY - 20 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(300 * scale.dx, startY + 100 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(240 * scale.dx, startY + 100 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(270 * scale.dx, startY + 120 * scale.dy),
        size: treeSize,
      ),
    ];
  }

  void buildBrownPath() {
    final brownPath = Path();
    double offsetX = 22 * scale.dx;
    double endY = ((startY - 399) * scale.dy).roundToDouble();

    brownPath.moveTo((171.077 + offsetX) * scale.dx, startY + (1 * scale.dy));
    brownPath.lineTo((171.077 + offsetX) * scale.dx, startY - (20 * scale.dy));
    brownPath.cubicTo(
      (161.952 + offsetX) * scale.dx,
      357.739 * scale.dy + endY,
      (299.578 + offsetX) * scale.dx,
      406.001 * scale.dy + endY,
      (303.077 + offsetX) * scale.dx,
      349.003 * scale.dy + endY,
    );
    brownPath.cubicTo(
      (345.077 + offsetX) * scale.dx,
      205 * scale.dy + endY,
      (42.077 + offsetX) * scale.dx,
      320.5 * scale.dy + endY,
      (64.57771 + offsetX) * scale.dx,
      216.5 * scale.dy + endY,
    );
    brownPath.cubicTo(
      (66.25806 + offsetX) * scale.dx,
      126.043 * scale.dy + endY,
      (283.577 + offsetX) * scale.dx,
      127.5 * scale.dy + endY,
      (259.577 + offsetX) * scale.dx,
      endY,
    );
    brownPath.lineTo((259.577 + offsetX) * scale.dx, endY - (4 * scale.dy));

    paths.add(brownPath);
  }

  void buildWhitePath() {
    final whitePath = Path();
    double offsetX = 22 * scale.dx * 2;
    double endY = ((startY - 399) * scale.dy).roundToDouble();

    whitePath.moveTo((147.077 + offsetX) * scale.dx, startY + (1 * scale.dy));
    whitePath.lineTo((147.077 + offsetX) * scale.dx, startY - (20 * scale.dy));
    whitePath.cubicTo(
      (137.952 + offsetX) * scale.dx,
      357.739 * scale.dy + endY,
      (275.578 + offsetX) * scale.dx,
      406.001 * scale.dy + endY,
      (279.077 + offsetX) * scale.dx,
      349.003 * scale.dy + endY,
    );
    whitePath.cubicTo(
      (321.077 + offsetX) * scale.dx,
      205 * scale.dy + endY,
      (18.077 + offsetX) * scale.dx,
      320.5 * scale.dy + endY,
      (40.57771 + offsetX) * scale.dx,
      216.5 * scale.dy + endY,
    );
    whitePath.cubicTo(
      (42.25806 + offsetX) * scale.dx,
      126.043 * scale.dy + endY,
      (259.577 + offsetX) * scale.dx,
      127.5 * scale.dy + endY,
      (235.577 + offsetX) * scale.dx,
      endY,
    );
    startY = (endY) * scale.dy;

    paths.add(whitePath);
  }

  void drawDashedPath(Canvas canvas, Path path, Paint paint) {
    ui.PathMetrics pathMetrics = path.computeMetrics();
    for (ui.PathMetric pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        Path dashPath =
            pathMetric.extractPath(distance, distance + 10 * scale.dx);
        canvas.drawPath(dashPath, paint);
        distance += 20 * scale.dx;
      }
    }
  }

  void drawBrownPath(Canvas canvas) {
    final brownPaint = Paint()
      ..color = const Color(0XFFDCB78D)
      ..strokeWidth = 50 * scale.dx
      ..style = PaintingStyle.stroke;

    canvas.drawPath(paths[0], brownPaint);
  }

  void drawWhitePath(Canvas canvas) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3 * scale.dx
      ..style = PaintingStyle.stroke;

    drawDashedPath(canvas, paths[1], whitePaint);
  }

  @override
  Path getPath() => paths[0];

  @override
  void drawBackground(Canvas canvas) {
    final backgroundPaint = Paint()
      ..color = const Color(0XFF8AD091)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(0, oldStartY - 404 * scale.dy, 411 * scale.dx, oldStartY),
      backgroundPaint,
    );
  }

  @override
  void drawCheckpoints(Canvas canvas) {
    // Drop shadow
    final Paint dropShadowPaint = Paint()
      ..color = const Color.fromARGB(64, 0, 0, 0);

    // Main checkpoint
    final Paint checkpointPaint = Paint()
      ..color = const Color(0XFF61C86C)
      ..style = PaintingStyle.fill;

    // Inner shadow
    final Paint innerShadowPaint = Paint()
      ..color = const Color.fromARGB(64, 0, 0, 0);

    for (Checkpoint checkpoint in checkpoints) {
      checkpoint.render(
        canvas,
        scale,
        dropShadowPaint,
        checkpointPaint,
        innerShadowPaint,
      );
    }
  }

  @override
  void drawDecorations(Canvas canvas) {
    for (dec.Decoration decoration in decorations) {
      decoration.render(canvas);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawBrownPath(canvas);
    drawWhitePath(canvas);
    drawCheckpoints(canvas);
    drawDecorations(canvas);
  }

  @override
  bool shouldRepaint(covariant TransitionRoad oldDelegate) => true;
}
