import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:playfit/camera_page.dart';
import 'package:playfit/components/level_cinematic/character.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/utils/image.dart';
import 'package:playfit/workout_progression_painter.dart';

class WorkoutProgressionPage extends StatefulWidget {
  final Difficulty difficulty;
  final List<String> images;
  final int startingPoint;
  final bool transition;
  final Map<String, List<dynamic>> workoutSessionExercises;
  final int currentExerciseIndex;

  const WorkoutProgressionPage({
    super.key,
    required this.difficulty,
    required this.images,
    required this.startingPoint,
    required this.workoutSessionExercises,
    required this.currentExerciseIndex,
    this.transition = false,
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

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationComplete();
      }
    });

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

  void _onAnimationComplete() {
    final String difficulty = widget.difficulty.toString().split('.').last;
    if (widget.startingPoint ==
        widget.workoutSessionExercises[difficulty]!.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    final String imageUrl = widget.images[widget.startingPoint];
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => CameraView(
          difficulty: difficulty,
          currentExerciseIndex: widget.currentExerciseIndex,
          landmarkImageUrl: imageUrl,
          workoutSessionExercises: widget.workoutSessionExercises,
        ),
      ),
    );
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
      future: Future.wait(
        widget.images.map((image) {
          return UIImageCacheManager().loadImage(image);
        }),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        images = {
          "hill": snapshot.data![0],
          "building": snapshot.data![1],
          "tree": snapshot.data![2],
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
                  painter: WorkoutProgressionPainter(
                    widget.difficulty,
                    images,
                    scale,
                    widget.transition,
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
