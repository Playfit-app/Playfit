import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/camera_page.dart';
import 'package:playfit/components/level_cinematic/character.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/utils/image.dart';
import 'package:playfit/workout_progression_painter.dart';
import 'package:playfit/home_page.dart';

class WorkoutProgressionPage extends StatefulWidget {
  final Difficulty difficulty;
  final List<String> images;
  final int startingPoint;
  final bool transition;
  final Map<String, List<dynamic>> workoutSessionExercises;
  final int currentExerciseIndex;
  final Map<String, String?> characterImages;

  const WorkoutProgressionPage({
    super.key,
    required this.difficulty,
    required this.images,
    required this.startingPoint,
    required this.workoutSessionExercises,
    required this.currentExerciseIndex,
    required this.characterImages,
    this.transition = false,
  });

  @override
  State<WorkoutProgressionPage> createState() => _WorkoutProgressionPageState();
}

class _WorkoutProgressionPageState extends State<WorkoutProgressionPage>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
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

    points = [
      Offset(30 * scale.dx, screenSize.height - 155 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 270 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 310 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 400 * scale.dy),
      Offset(30 * scale.dx, screenSize.height - 450 * scale.dy),
      Offset(260 * scale.dx, screenSize.height - 550 * scale.dy),
    ];
  }

  /// Completes the workout session by sending a PATCH request to the server with the difficulty level.
  /// 
  /// `difficulty` is a string representing the difficulty level of the workout session.
  /// 
  /// Returns a [Future] that completes when the request is done.
  Future<void> completeWorkoutSession(String difficulty) async {
    final String baseUrl = '${dotenv.env['SERVER_BASE_URL']}/api/workout';
    final String? token = await storage.read(key: 'token');

    final response = await http
        .patch(Uri.parse('$baseUrl/update_workout_session/'), headers: {
      'Authorization': 'Token $token',
    }, body: {
      'difficulty': difficulty,
    });

    if (response.statusCode == 200) {
    } else {
      print("Can't update workout session");
    }
  }

  /// Handles the completion of the animation by checking if the user has reached the last exercise.
  /// If so, it completes the workout session and navigates to the home page.
  /// 
  /// If the user has not reached the last exercise, it navigates to the CameraView page
  /// with the appropriate parameters.
  void _onAnimationComplete() async {
    String difficulty = "";
    switch (widget.difficulty) {
      case Difficulty.easy:
        difficulty = "beginner";
        break;
      case Difficulty.medium:
        difficulty = "intermediate";
        break;
      case Difficulty.hard:
        difficulty = "advanced";
        break;
    }
    if (widget.startingPoint ==
        widget.workoutSessionExercises[difficulty]!.length - 1) {
      await completeWorkoutSession(difficulty);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => HomePage(
            // completedDifficulty: difficulty,
            // workoutDone: true,
          ),
        ),
        (Route<dynamic> route) => false,
      );
      return;
    }
    String imageUrl = widget.images[3];

    imageUrl = "/media${imageUrl.split('/media').last}";

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraView(
          difficulty: difficulty,
          currentExerciseIndex: widget.currentExerciseIndex,
          landmarkImageUrl: imageUrl,
          workoutSessionExercises: widget.workoutSessionExercises,
          characterImages: widget.characterImages,
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

    // Ensure that the images are loaded before proceeding
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
        _controller = AnimationController(
          vsync: this,
          duration: const Duration(seconds: 5),
        )..forward();

        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _onAnimationComplete();
          }
        });

        _animation =
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

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
                images: widget.characterImages,
              ),
            ],
          ),
        );
      },
    );
  }
}
