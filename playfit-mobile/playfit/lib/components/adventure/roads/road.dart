import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/adventure/checkpoint.dart';
import 'package:playfit/components/adventure/decoration.dart' as dec;

abstract class Road extends CustomPainter {
  double startY;
  Size screenSize;
  Offset scale;
  Path path = Path();
  List<Checkpoint> checkpoints = [];
  List<dec.Decoration> decorations = [];
  Map<String, dynamic> decorationImages;
  int cityIndex;

  Road({
    required this.startY,
    required this.screenSize,
    required this.scale,
    required this.decorationImages,
    required this.cityIndex,
  });

  void setCheckpoints(int count) {
    final Path path = getPath();
    final ui.PathMetrics pathMetrics = path.computeMetrics();

    checkpoints.clear();
    for (ui.PathMetric pathMetric in pathMetrics) {
      for (int i = 0; i < count; i++) {
        final double distance = pathMetric.length * (i + 1) / (count + 1);
        final ui.Tangent tangent = pathMetric.getTangentForOffset(distance)!;
        final Offset position = tangent.position;
        final Checkpoint checkpoint = Checkpoint(
          position: position,
          id: i,
        );
        checkpoints.add(checkpoint);
      }
    }
  }

  List<Checkpoint> getCheckpoints() => checkpoints;

  double getStartY() => startY;

  void setDecorations();

  Path getPath();

  void drawBackground(Canvas canvas);

  void drawCheckpoints(Canvas canvas);

  void drawDecorations(Canvas canvas);
}
