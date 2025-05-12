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
    required super.screenSize,
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
        position: Offset(100 * scale.dx, startY + 60 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(200 * scale.dx, startY + 225 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(220 * scale.dx, startY + 205 * scale.dy),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(260 * scale.dx, startY + 250 * scale.dy),
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
        position: Offset(50 * scale.dx, startY + 50 * scale.dy),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(30 * scale.dx, startY + 380 * scale.dy),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(95 * scale.dx, startY + 380 * scale.dy),
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

    // OffsetX based on 22px from 411px width → 22 / 411 ≈ 0.0535
    double offsetX = screenSize.width * 0.0535;
    double endY = (startY - screenSize.height * scale.dy).roundToDouble();

    // Shortcut functions for percentage-based coordinates
    double px(double originalX) =>
        screenSize.width *
        ((originalX / 411) + (offsetX / screenSize.width)) *
        scale.dx;
    double py(double originalY) =>
        screenSize.height * (originalY / 798) * scale.dy + endY;

    greyPath.moveTo(px(259.577), endY + screenSize.height * scale.dy);

    greyPath.cubicTo(
      px(251.577),
      py(635),
      px(-20.9231),
      py(668),
      px(33.0769),
      py(583),
    );

    greyPath.cubicTo(
      px(87.0769),
      py(498),
      px(307.577),
      py(583),
      px(313.577),
      py(470),
    );

    greyPath.cubicTo(
      px(319.577),
      py(357),
      px(15.5769),
      py(375.5),
      px(67.5769),
      py(258.5),
    );

    greyPath.cubicTo(
      px(119.577),
      py(141.5),
      px(243.577),
      py(245.5),
      px(291.577),
      py(162.5),
    );

    greyPath.cubicTo(
      px(339.577),
      py(79.5),
      px(171.077),
      py(24.5),
      px(171.077),
      endY < 0 ? 0 : endY,
    );

    paths.add(greyPath);
  }

  void buildWhitePath() {
    final whitePath = Path();

    // 22 * 2 = 44 → offsetX as a percent of 411 width = 44 / 411 ≈ 0.1071
    double offsetX = screenSize.width * 0.1071;
    double endY = (startY - screenSize.height * scale.dy).roundToDouble();

    // Helpers for clean coordinate translation
    double px(double originalX) =>
        screenSize.width *
        ((originalX / 411) + (offsetX / screenSize.width)) *
        scale.dx;
    double py(double originalY) =>
        screenSize.height * (originalY / 798) * scale.dy + endY;

    whitePath.moveTo(px(235.577), endY + screenSize.height * scale.dy);

    whitePath.cubicTo(
      px(227.577),
      py(635),
      px(-44.9231),
      py(668),
      px(9.07689),
      py(583),
    );

    whitePath.cubicTo(
      px(63.0769),
      py(498),
      px(283.577),
      py(583),
      px(289.577),
      py(470),
    );

    whitePath.cubicTo(
      px(295.577),
      py(357),
      px(-8.4231),
      py(375.5),
      px(43.5769),
      py(258.5),
    );

    whitePath.cubicTo(
      px(95.5769),
      py(141.5),
      px(219.577),
      py(245.5),
      px(267.577),
      py(162.5),
    );

    whitePath.cubicTo(
      px(315.577),
      py(79.5),
      px(147.077),
      py(24.5),
      px(147.077),
      endY < 0 ? 0 : endY,
    );

    // Update startY after the path
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

    // Convert 411 and 798 to percentage-based dimensions
    final double left = 0;
    final double top =
        oldStartY - (screenSize.height * scale.dy); // 798 is 100% of height
    final double right = screenSize.width * scale.dx; // 411 is 100% of width
    final double bottom = oldStartY;

    canvas.drawRect(
      Rect.fromLTRB(left, top, right, bottom),
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
