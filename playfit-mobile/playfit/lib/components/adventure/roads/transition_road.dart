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
    required super.screenSize,
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

    // OffsetX based on 22 / 411 ≈ 0.0535
    double offsetX = screenSize.width * 0.0535;
    double endY =
        (startY - (screenSize.height * 0.5) * scale.dy).roundToDouble();

    // Helpers for relative positioning
    double px(double originalX) =>
        screenSize.width *
        ((originalX / 411) + (offsetX / screenSize.width)) *
        scale.dx;
    double py(double originalY) =>
        screenSize.height * (originalY / 798) * scale.dy + endY;

    brownPath.moveTo(
      px(171.077),
      startY + (1 * scale.dy),
    );

    brownPath.lineTo(
      px(171.077),
      startY - (20 * scale.dy),
    );

    brownPath.cubicTo(
      px(161.952),
      py(357.739),
      px(299.578),
      py(406.001),
      px(303.077),
      py(349.003),
    );

    brownPath.cubicTo(
      px(345.077),
      py(205),
      px(42.077),
      py(320.5),
      px(64.57771),
      py(216.5),
    );

    brownPath.cubicTo(
      px(66.25806),
      py(126.043),
      px(283.577),
      py(127.5),
      px(259.577),
      endY,
    );

    brownPath.lineTo(
      px(259.577),
      endY - (4 * scale.dy),
    );

    paths.add(brownPath);
  }

  void buildWhitePath() {
    final whitePath = Path();

    // 22 * 2 = 44 → 44 / 411 ≈ 0.1071
    double offsetX = screenSize.width * 0.1071;
    double endY =
        (startY - (screenSize.height * 0.5) * scale.dy).roundToDouble();

    // Helper functions
    double px(double originalX) =>
        screenSize.width *
        ((originalX / 411) + (offsetX / screenSize.width)) *
        scale.dx;
    double py(double originalY) =>
        screenSize.height * (originalY / 798) * scale.dy + endY;

    whitePath.moveTo(
      px(147.077),
      startY + (1 * scale.dy),
    );

    whitePath.lineTo(
      px(147.077),
      startY - (20 * scale.dy),
    );

    whitePath.cubicTo(
      px(137.952),
      py(357.739),
      px(275.578),
      py(406.001),
      px(279.077),
      py(349.003),
    );

    whitePath.cubicTo(
      px(321.077),
      py(205),
      px(18.077),
      py(320.5),
      px(40.57771),
      py(216.5),
    );

    whitePath.cubicTo(
      px(42.25806),
      py(126.043),
      px(259.577),
      py(127.5),
      px(235.577),
      endY,
    );

    startY = endY;

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
      ..color = const Color(0xFF8AD091)
      ..style = PaintingStyle.fill;

    // 404 / 798 ≈ 0.5063 → 50.63% of screen height
    final double left = 0;
    final double top = oldStartY - (screenSize.height * 0.5063 * scale.dy);
    final double right =
        screenSize.width * scale.dx; // full width (411 / 411 = 1)
    final double bottom = oldStartY;

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
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
