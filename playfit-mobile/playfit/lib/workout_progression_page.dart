import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playfit/components/level_cinematic/character.dart';
import 'package:playfit/components/level_cinematic/decorations.dart';
import 'package:playfit/components/level_cinematic/landmark.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/utils/image.dart';
import 'package:playfit/components/level_cinematic/hill_path_clipper.dart';

class WorkoutProgressionPage extends StatefulWidget {
  final Difficulty difficulty;
  final List<String> images;
  final int startingPoint;

  const WorkoutProgressionPage({
    super.key,
    required this.difficulty,
    required this.images,
    required this.startingPoint,
  });

  @override
  State<WorkoutProgressionPage> createState() => _WorkoutProgressionPageState();
}

class _WorkoutProgressionPageState extends State<WorkoutProgressionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Offset> points;
  late Map<String, ui.Image> images;

  @override
  void initState() {
    super.initState();
    images = {};

    final screenSize = MediaQueryData.fromView(
            WidgetsBinding.instance.platformDispatcher.views.first)
        .size;
    final scale = Offset(screenSize.width / 411, screenSize.height / 831);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    points = [
      Offset(30 * scale.dx, screenSize.height - 155 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 270 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 310 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 400 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 450 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 550 * scale.dy),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Offset(
      MediaQuery.of(context).size.width / 411,
      MediaQuery.of(context).size.height / 831,
    );

    return FutureBuilder(
      future: Future.wait([
        UIImageCacheManager()
            .loadImageFromAssets("assets/images/hill_path.png"),
        UIImageCacheManager().loadImageFromAssets("assets/images/tree.png"),
        UIImageCacheManager().loadImageFromAssets("assets/images/building.png"),
        UIImageCacheManager()
            .loadImageFromAssets("assets/images/sacre_coeur.png"),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        images = {
          "hill": snapshot.data![0],
          "tree": snapshot.data![1],
          "building": snapshot.data![2],
          "landmark": snapshot.data![3],
        };

        return Scaffold(
          body: Stack(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                  painter: _HillPainter(
                    widget.difficulty,
                    images,
                    scale,
                  ),
                ),
              ),
              Character(
                animation: _animation,
                points: points,
                startingPoint: widget.startingPoint,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HillPainter extends CustomPainter {
  final Difficulty difficulty;
  final Map<String, ui.Image> images;
  final Offset scale;
  late Decorations decorations;
  late Landmark landmark;

  _HillPainter(
    this.difficulty,
    this.images,
    this.scale,
  ) : super() {
    decorations = Decorations(
      images: images,
      nbHills: difficulty.index + 3,
      scale: scale,
      screenHeight: scale.dy * 831,
      hillHeight: scale.dy * 831 / 2,
    );
    landmark = Landmark(
      image: images["landmark"]!,
      scale: scale,
      difficulty: difficulty,
      screenHeight: scale.dy * 831,
      hillHeight: scale.dy * 831 / 2,
    );
  }

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
    final hillHeight = size.height / 2 * scale.dy;
    double startY = size.height - (hillHeight / 6) * (difficulty.index + 2);
    // final hillPaint = Paint()
    //   ..shader = ImageShader(
    //     images["hill"]!,
    //     ui.TileMode.clamp,
    //     ui.TileMode.clamp,
    //     Matrix4.identity().scaled(scale.dx, scale.dy).storage,
    //   );
    final hillPaint = Paint()..color = Colors.grey;
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
        canvas.drawPath(
          hillPath.getClip(size),
          hillPaint,
        );
        canvas.restore();
      } else {
        // Drop Shadow
        canvas.drawPath(
          hillPath.getClip(size).shift(const Offset(0, -7)),
          shadowPaint,
        );
        canvas.drawPath(
          backgroundHillPath.getClip(size),
          backgroundHillPaint,
        );
        canvas.drawPath(
          hillPath.getClip(size),
          hillPaint,
        );
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
