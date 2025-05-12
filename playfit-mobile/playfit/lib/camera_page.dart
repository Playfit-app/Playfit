import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/workout_analyzer.dart';
import 'package:playfit/image_converter.dart';
import 'package:playfit/components/camera/left_box_widget.dart';
import 'package:playfit/components/camera/bottom_box_widget.dart';
import 'package:playfit/components/camera/celebration_overlay.dart';
import 'package:playfit/workout_progression_page.dart';

enum BoxType { left, bottom }

class CameraView extends StatefulWidget {
  final Map<String, List<dynamic>> workoutSessionExercises;
  final String difficulty;
  final int currentExerciseIndex;
  final String landmarkImageUrl;
  final Map<String, String?> characterImages;
  final BoxType boxType;

  const CameraView({
    super.key,
    required this.workoutSessionExercises,
    required this.difficulty,
    required this.currentExerciseIndex,
    required this.landmarkImageUrl,
    required this.characterImages,
    this.boxType = BoxType.left,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isDetecting = false;
  final WorkoutAnalyzer _workoutAnalyzer = WorkoutAnalyzer();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  late WorkoutType _workoutType;
  late String _exerciseName;

  int _count = 0;
  late int _targetCount;
  bool _showCelebration = false;
  bool _showStartButton = true;
  int _celebrationCountdown = 5;
  Timer? _celebrationTimer;
  bool _celebrationStarted = false;

  WorkoutType workoutTypeFromName(String name) {
    switch (name.toLowerCase().replaceAll('-', '')) {
      case 'squat':
        return WorkoutType.squat;
      case 'jumpingjack':
        return WorkoutType.jumpingJack;
      case 'pushup':
        return WorkoutType.pushUp;
      case 'pullup':
        return WorkoutType.pullUp;
      default:
        throw Exception('Workout type not recognized: $name');
    }
  }

  @override
  void initState() {
    super.initState();

    final exercise = widget.workoutSessionExercises[widget.difficulty]![
        widget.currentExerciseIndex];
    _workoutType = workoutTypeFromName(exercise['name']);
    _targetCount = exercise['repetitions'];
    _exerciseName = exercise['name'];

    initCamera();
    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];
      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;
          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting(); // Triggers the countdown
          }
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);

        if (_count == _targetCount) {
          _showCelebration = true;
        }
      });
    });
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.high,
    );
    await _controller?.initialize();

    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];

      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;

          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting();
          }
        });
      }
    });

    if (mounted) {
      setState(() {});
    }
  }
  //end function after help

  void _startDetecting() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) return;
      setState(() {
        _showStartButton = false;
      });

      _startTimer();
      _controller!.startImageStream((image) async {
        if (_isDetecting) return;
        _isDetecting = true;

        try {
          final inputImage = ImageUtils.getInputImage(image, _controller);
          await _workoutAnalyzer.detectWorkout(inputImage, _workoutType);
        } catch (e) {
        } finally {
          _isDetecting = false;
        }
      });
    }
  }

  void _stopDetecting() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      _timer?.cancel();
      await _controller!.stopImageStream();
      _isDetecting = false;
    }

    // Démarrer le compte à rebours
    _celebrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _celebrationCountdown--;
      });
      if (_celebrationCountdown == 0) {
        _celebrationTimer?.cancel();
        _goToProgressionPage();
      }
    });
  }

  void _goToProgressionPage() {
    final Difficulty difficulty = widget.difficulty == "beginner"
        ? Difficulty.easy
        : widget.difficulty == "intermediate"
            ? Difficulty.medium
            : Difficulty.hard;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutProgressionPage(
          difficulty: difficulty,
          images: [
            "assets/images/pebble_path.jpg",
            "${dotenv.env['SERVER_BASE_URL']}/media/decorations/building.webp",
            "${dotenv.env['SERVER_BASE_URL']}/media/decorations/tree.webp",
            "${dotenv.env['SERVER_BASE_URL']}${widget.landmarkImageUrl}",
          ],
          startingPoint: widget.currentExerciseIndex,
          workoutSessionExercises: widget.workoutSessionExercises,
          currentExerciseIndex: widget.currentExerciseIndex + 1,
          characterImages: widget.characterImages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      body: _controller != null && _controller!.value.isInitialized
          ? Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Text(
                    _exerciseName
                        .toUpperCase(), // tu peux enlever le toUpperCase() si tu veux le nom original
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 1, 1),
                    ),
                  ),
                ),

                Center(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),
                if (widget.boxType == BoxType.left)
                  LeftBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),
                if (widget.boxType == BoxType.bottom)
                  BottomBoxWidget(
                      elapsedTime: _elapsedTime,
                      count: _count,
                      targetCount: _targetCount),

                // Overlay when count hits the target
                if (_showCelebration)
                  CelebrationOverlay(finalTime: _elapsedTime),
                if (_showCelebration && _celebrationCountdown > 0)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Text(
                      "Prochaine étape dans $_celebrationCountdown...",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black,
                            offset: Offset(1.5, 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_showStartButton)
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Future.delayed(const Duration(seconds: 3), () {
                          _startDetecting();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Démarrer',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebrationTimer?.cancel();
    _workoutAnalyzer.dispose();
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        _controller!.stopImageStream();
      }
      _controller!.dispose();
    }
    super.dispose();
  }
}
