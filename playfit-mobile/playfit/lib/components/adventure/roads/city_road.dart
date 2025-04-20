import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/roads/road.dart';
import 'package:playfit/components/adventure/checkpoint.dart';
import 'package:playfit/components/adventure/decoration.dart' as dec;

class CityRoad extends Road {
  final List<Path> paths = [];
  late double oldStartY;

  CityRoad({
    required super.startY,
    required super.scale,
    required super.decorationImages,
    required super.cityIndex,
  }) {
    oldStartY = startY;
    buildGreyPath();
    buildWhitePath();
    setCheckpoints(6);
    setDecorations();
  }

  @override
  void setDecorations() {
    final ui.Image? treeImage = decorationImages['tree'];
    final ui.Image? buildingImage = decorationImages['building'];
    final ui.Image? landmarkImage = decorationImages['country'][cityIndex].last;

    if (treeImage == null || buildingImage == null || landmarkImage == null) {
      return;
    }

    const Size treeSize = Size(79, 118);
    const Size buildingSize = Size(75, 131);
    Size landmarkSize =
        Size(landmarkImage.width.toDouble(), landmarkImage.height.toDouble());

    decorations = [
      // Trees
      dec.Decoration(
        image: treeImage,
        position: Offset(100 * scale.dx, startY + 80 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(200 * scale.dx, startY + 245 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(220 * scale.dx, startY + 225 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(260 * scale.dx, startY + 270 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(200 * scale.dx, oldStartY - 300 * scale.dy),
        size: treeSize,
      ),

      // Buildings
      dec.Decoration(
        image: buildingImage,
        position: Offset(50 * scale.dx, startY + 70 * scale.dy),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(30 * scale.dx, startY + 400 * scale.dy),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(95 * scale.dx, startY + 400 * scale.dy),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(280 * scale.dx, oldStartY - 280 * scale.dy),
        size: buildingSize,
      ),

      // Landmarks
      dec.Decoration(
        image: landmarkImage,
        position: Offset(300 * scale.dx, startY + 170 * scale.dy),
        size: landmarkSize,
      ),
    ];
  }

  void buildGreyPath() {
    final greyPath = Path();
    double offsetX = 22 * scale.dx;
    double endY = ((startY - 798) * scale.dy).roundToDouble();

    greyPath.moveTo((259.577 + offsetX) * scale.dx, (endY + 798) * scale.dy);
    greyPath.cubicTo(
        (251.577 + offsetX) * scale.dx,
        635 * scale.dy + endY,
        (-20.9231 + offsetX) * scale.dx,
        668 * scale.dy + endY,
        (33.0769 + offsetX) * scale.dx,
        583 * scale.dy + endY);
    greyPath.cubicTo(
        (87.0769 + offsetX) * scale.dx,
        498 * scale.dy + endY,
        (307.577 + offsetX) * scale.dx,
        583 * scale.dy + endY,
        (313.577 + offsetX) * scale.dx,
        470 * scale.dy + endY);
    greyPath.cubicTo(
        (319.577 + offsetX) * scale.dx,
        357 * scale.dy + endY,
        (15.5769 + offsetX) * scale.dx,
        375.5 * scale.dy + endY,
        (67.5769 + offsetX) * scale.dx,
        258.5 * scale.dy + endY);
    greyPath.cubicTo(
        (119.577 + offsetX) * scale.dx,
        141.5 * scale.dy + endY,
        (243.577 + offsetX) * scale.dx,
        245.5 * scale.dy + endY,
        (291.577 + offsetX) * scale.dx,
        162.5 * scale.dy + endY);
    greyPath.cubicTo(
        (339.577 + offsetX) * scale.dx,
        79.5 * scale.dy + endY,
        (171.077 + offsetX) * scale.dx,
        24.5 * scale.dy + endY,
        (171.077 + offsetX) * scale.dx,
        endY);

    paths.add(greyPath);
  }

  void buildWhitePath() {
    final whitePath = Path();
    double offsetX = 22 * scale.dx * 2;
    double endY = ((startY - 798) * scale.dy).roundToDouble();

    whitePath.moveTo((235.577 + offsetX) * scale.dx, (endY + 798) * scale.dy);
    whitePath.cubicTo(
        (227.577 + offsetX) * scale.dx,
        635 * scale.dy + endY,
        (-44.9231 + offsetX) * scale.dx,
        668 * scale.dy + endY,
        (9.07689 + offsetX) * scale.dx,
        583 * scale.dy + endY);
    whitePath.cubicTo(
        (63.0769 + offsetX) * scale.dx,
        498 * scale.dy + endY,
        (283.577 + offsetX) * scale.dx,
        583 * scale.dy + endY,
        (289.577 + offsetX) * scale.dx,
        470 * scale.dy + endY);
    whitePath.cubicTo(
        (295.577 + offsetX) * scale.dx,
        357 * scale.dy + endY,
        (-8.4231 + offsetX) * scale.dx,
        375.5 * scale.dy + endY,
        (43.5769 + offsetX) * scale.dx,
        258.5 * scale.dy + endY);
    whitePath.cubicTo(
        (95.5769 + offsetX) * scale.dx,
        141.5 * scale.dy + endY,
        (219.577 + offsetX) * scale.dx,
        245.5 * scale.dy + endY,
        (267.577 + offsetX) * scale.dx,
        162.5 * scale.dy + endY);
    whitePath.cubicTo(
        (315.577 + offsetX) * scale.dx,
        79.5 * scale.dy + endY,
        (147.077 + offsetX) * scale.dx,
        24.5 * scale.dy + endY,
        (147.077 + offsetX) * scale.dx,
        endY);
    startY = endY * scale.dy;

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

  void drawGreyPath(Canvas canvas) {
    final greyPaint = Paint()
      ..color = const Color.fromARGB(255, 129, 147, 167)
      ..strokeWidth = 50 * scale.dx
      ..style = PaintingStyle.stroke;

    canvas.drawPath(paths[0], greyPaint);
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
      ..color = const Color.fromARGB(255, 197, 222, 250)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTRB(0, oldStartY - (802 * scale.dy), 411 * scale.dx, oldStartY),
      backgroundPaint,
    );
  }

  @override
  void drawCheckpoints(Canvas canvas) {
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
    drawGreyPath(canvas);
    drawWhitePath(canvas);
    drawCheckpoints(canvas);
    drawDecorations(canvas);
  }

  @override
  bool shouldRepaint(covariant CityRoad oldDelegate) => true;
}
