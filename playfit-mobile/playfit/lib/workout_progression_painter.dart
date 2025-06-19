import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/components/level_cinematic/decorations.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/components/level_cinematic/hill_path_clipper.dart';
import 'package:playfit/components/level_cinematic/landmark.dart';

class WorkoutProgressionPainter extends CustomPainter {
  final Difficulty difficulty;
  final Map<String, ui.Image> images;
  final Offset scale;
  final bool transition;
  late Decorations decorations;
  late Landmark landmark;

  WorkoutProgressionPainter(
    this.difficulty,
    this.images,
    this.scale,
    this.transition,
  ) : super() {
    decorations = Decorations(
      images: images,
      nbHills: difficulty.index + 3,
      scale: scale,
      screenHeight: scale.dy * 831,
      hillHeight: scale.dy * 831 / 2,
      transition: transition,
    );
    landmark = Landmark(
      image: images["landmark"]!,
      scale: scale,
      difficulty: difficulty,
      screenHeight: scale.dy * 831,
      hillHeight: scale.dy * 831 / 2,
    );
  }

  /// Draws a white gradient at the top of the canvas.
  /// This gradient fades from white to transparent,
  /// creating a smooth transition effect at the top of the screen.
  ///
  /// `canvas` is the canvas on which to draw the gradient.
  /// `size` is the size of the canvas, used to determine the dimensions of the gradient.
  void _drawWhiteTopGradient(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomLeft,
        colors: [
          Colors.white,
          Colors.white.withAlpha(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 292));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 292), paint);
  }

  /// Draws a background rectangle with a light blue color.
  /// This rectangle covers the entire canvas area,
  /// providing a base background for the painting.
  ///
  /// `canvas` is the canvas on which to draw the background.
  /// `size` is the size of the canvas, used to determine the dimensions of the rectangle.
  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color.fromARGB(255, 197, 222, 250)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final hillImage = images["hill"]!;
    final hillHeight = size.height / 2 * scale.dy;
    double startY = size.height - (hillHeight / 6) * (difficulty.index + 2);
    final hillPaint = Paint()
      ..shader = ImageShader(
        images["hill"]!,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Matrix4.identity().scaled(scale.dx, scale.dy).storage,
      );
    final Paint backgroundHillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF16144D).withValues(alpha: 0.55),
          const Color(0xFFFFFAE5).withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, startY, size.width, size.height / 2));

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRect(
      Rect.fromLTWH(0, startY, size.width, size.height / 2),
      backgroundHillPaint,
    );

    _drawBackground(canvas, size);

    for (var i = difficulty.index + 2; i >= 0; i--) {
      final hillPath = HillPathClipper(
        startY: startY,
        scale: scale,
        height: hillHeight,
      );
      final backgroundHillPath = BackgroundHillPathClipper(
        startY: startY,
        scale: scale,
        height: size.height / 2 * scale.dy,
      );
      final hill = hillPath.getClip(size);
      // Keep aspect ratio for path texture
      double imageAspectRatio = hillImage.width / hillImage.height;
      double targetWidth = hill.getBounds().width;
      double targetHeight = targetWidth / imageAspectRatio;

      // if the index is odd, we flip the hill horizontally
      // and rotate it 10 degrees to the left
      // to create a zigzag effect
      if (i.isOdd) {
        Offset pivot = Offset(size.width / 2, size.height / 2);
        canvas.save();
        canvas.translate(pivot.dx, pivot.dy);
        // Rotate 10 degrees to the left
        canvas.rotate(-10 * math.pi / 180);
        canvas.translate(-pivot.dx, -pivot.dy);
        canvas.scale(-1, 1);
        canvas.translate(-size.width + 50, 0);

        // Drop Shadow
        canvas.drawPath(
          hillPath.getClip(size).shift(const Offset(0, -7)),
          shadowPaint,
        );
        // Background Hill
        canvas.drawPath(
          backgroundHillPath.getClip(size),
          backgroundHillPaint,
        );
        // Hill
        canvas.save();
        canvas.clipPath(hill);
        final srcRect = Rect.fromLTWH(
          0,
          0,
          hillImage.width.toDouble(),
          hillImage.height.toDouble(),
        );
        final dstRect = Rect.fromLTWH(
          hill.getBounds().left,
          hill.getBounds().top + (hill.getBounds().height - targetHeight),
          targetWidth,
          targetHeight,
        );
        canvas.drawImageRect(hillImage, srcRect, dstRect, hillPaint);
        canvas.restore();
        canvas.restore();
      } else {
        // Drop Shadow
        canvas.drawPath(
          hillPath.getClip(size).shift(const Offset(0, -7)),
          shadowPaint,
        );
        // Background Hill
        canvas.drawPath(
          backgroundHillPath.getClip(size),
          backgroundHillPaint,
        );
        // Hill
        canvas.save();
        canvas.clipPath(hill);
        final srcRect = Rect.fromLTWH(
          0,
          0,
          hillImage.width.toDouble(),
          hillImage.height.toDouble(),
        );
        final dstRect = Rect.fromLTWH(
          hill.getBounds().left,
          hill.getBounds().top + (hill.getBounds().height - targetHeight),
          targetWidth,
          targetHeight,
        );
        canvas.drawImageRect(hillImage, srcRect, dstRect, hillPaint);
        canvas.restore();
      }
      startY += hillHeight / 6;
    }

    decorations.render(canvas, size);

    landmark.render(canvas, size);

    _drawWhiteTopGradient(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
