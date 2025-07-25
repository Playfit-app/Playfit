import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/roads/road.dart';
import 'package:playfit/components/adventure/checkpoint.dart';
import 'package:playfit/components/adventure/decoration.dart' as dec;

class CityRoad extends Road {
  final List<Path> paths = [];
  late double oldStartY;
  late Color cityColor;

  CityRoad({
    required super.startY,
    required super.screenSize,
    required super.decorationImages,
    required super.cityIndex,
    required this.cityColor,
  }) {
    oldStartY = startY;
    cityColor = cityColor;
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

    Size scale = Size(
      screenSize.width / 411,
      screenSize.height / 798,
    );
    Size treeSize = Size(79 * scale.width, 118 * scale.height);
    Size buildingSize = Size(75 * scale.width, 131 * scale.height);
    Size landmarkSize = Size(landmarkImage.width.toDouble() * scale.width,
        landmarkImage.height.toDouble() * scale.height);

    decorations = [
      // Trees
      dec.Decoration(
        image: treeImage,
        position: Offset(100 * scale.width, startY + 60 * scale.height),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(200 * scale.width, startY + 225 * scale.height),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(220 * scale.width, startY + 205 * scale.height),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(260 * scale.width, startY + 250 * scale.height),
        size: treeSize,
      ),
      dec.Decoration(
        image: treeImage,
        position: Offset(200 * scale.width, oldStartY - 300 * scale.height),
        size: treeSize,
      ),

      // Buildings
      dec.Decoration(
        image: buildingImage,
        position: Offset(50 * scale.width, startY + 50 * scale.height),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(30 * scale.width, startY + 380 * scale.height),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(95 * scale.width, startY + 380 * scale.height),
        size: buildingSize,
      ),
      dec.Decoration(
        image: buildingImage,
        position: Offset(280 * scale.width, oldStartY - 280 * scale.height),
        size: buildingSize,
      ),

      // Landmarks
      dec.Decoration(
        image: landmarkImage,
        position: Offset(300 * scale.width, startY + 170 * scale.height),
        size: landmarkSize,
      ),
    ];
  }

  void buildGreyPath() {
    final greyPath = Path();
    double offsetX = screenSize.width * 0.0535;
    double endY = (startY - screenSize.height).roundToDouble();
    // Shortcut functions for percentage-based coordinates
    double px(double originalX) =>
        screenSize.width * ((originalX / 411) + (offsetX / screenSize.width));
    double py(double originalY) => screenSize.height * (originalY / 798) + endY;

    greyPath.moveTo(px(259.577), endY + screenSize.height);

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

    double offsetX = screenSize.width * 0.1071;
    double endY = (startY - screenSize.height).roundToDouble();

    // Helpers for clean coordinate translation
    double px(double originalX) =>
        screenSize.width * ((originalX / 411) + (offsetX / screenSize.width));
    double py(double originalY) => screenSize.height * (originalY / 798) + endY;

    whitePath.moveTo(px(235.577), endY + screenSize.height);

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
        Path dashPath = pathMetric.extractPath(distance, distance + 10);
        canvas.drawPath(dashPath, paint);
        distance += 20;
      }
    }
  }

  void drawGreyPath(Canvas canvas) {
    final greyPaint = Paint()
      ..color = const Color.fromARGB(255, 129, 147, 167)
      ..strokeWidth = 50
      ..style = PaintingStyle.stroke;

    canvas.drawPath(paths[0], greyPaint);
  }

  void drawWhitePath(Canvas canvas) {
    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    drawDashedPath(canvas, paths[1], whitePaint);
  }

  @override
  Path getPath() => paths[0];

  @override
  void drawBackground(Canvas canvas) {
    final backgroundPaint = Paint()
      ..color = cityColor
      ..style = PaintingStyle.fill;

    final double left = 0;
    final double top = oldStartY - (screenSize.height);
    final double right = screenSize.width;
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
