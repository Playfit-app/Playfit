import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/level_cinematic/difficulty.dart';
import 'package:playfit/services/tts_service.dart';
import 'package:playfit/services/workout_timer_service.dart';
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
  final String city;
  final int level;

  const CameraView({
    super.key,
    required this.workoutSessionExercises,
    required this.difficulty,
    required this.currentExerciseIndex,
    required this.landmarkImageUrl,
    required this.characterImages,
    required this.boxType,
    required this.city,
    required this.level,
  });

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isDetecting = false;
  final WorkoutAnalyzer _workoutAnalyzer = WorkoutAnalyzer();
  WorkoutTimerService _workoutTimerService = WorkoutTimerService();
  late WorkoutType _workoutType;
  late String _exerciseName;
  late Duration _elapsedTime;

  int _count = 0;
  late int _targetCount;
  bool _showCelebration = false;
  bool _showStartButton = true;
  int _celebrationCountdown = 5;
  Timer? _celebrationTimer;
  bool _celebrationStarted = false;
  late FlutterTts _flutterTts;

  /// Converts a workout name to a [WorkoutType].
  /// This method maps the name of the workout to its corresponding enum value.
  /// Throws an exception if the name is not recognized.
  ///
  /// `name` is the name of the workout as a string.
  ///
  /// Returns a [WorkoutType] corresponding to the name.
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

    _elapsedTime = _workoutTimerService.elapsed;
    _workoutTimerService.onTick = (elapsed) {
      if (mounted) {
        setState(() {
          _elapsedTime = elapsed;
        });
      }
    };
    final exercise = widget.workoutSessionExercises[widget.difficulty]![
        widget.currentExerciseIndex];
    _workoutType = workoutTypeFromName(exercise['name']);
    _targetCount = exercise['repetitions'];
    _exerciseName = exercise['name'];
    _flutterTts = FlutterTts();
    configureTtsLanguage(_flutterTts);

    initCamera();
    // Listen for changes in workout counts to update the count and trigger announcements
    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];
      if (count != null && count > _count && count <= _targetCount) {
        setState(() {
          _count = count;
          _announceCount();
          if (_count == _targetCount && !_celebrationStarted) {
            _celebrationStarted = true;
            _showCelebration = true;
            _stopDetecting(); // Triggers the countdown
          }
        });
      }
    });
  }

  /// Announces the current count or target count using Text-to-Speech (TTS).
  /// This method stops any ongoing speech and speaks the current count.
  /// If the count matches the target count, it announces a congratulatory message.
  ///
  /// Returns a [Future] that completes when the speech is done.
  Future<void> _announceCount() async {
    await _flutterTts.stop();
    if (_count == _targetCount) {
      await _flutterTts
          .speak("Bravo ! Tu as atteint $_targetCount répétitions.");
    } else {
      await _flutterTts.speak("$_count");
    }
  }

  /// Starts a timer that updates the elapsed time every second.
  /// This method also checks if the target count has been reached
  /// and sets a flag to show the celebration overlay.
  ///
  /// Returns a [void] that completes when the timer is started.
  void _startTimer() {
    _workoutTimerService.start();
  }

  /// Initializes the camera and sets up the camera controller.
  /// This method retrieves the available cameras, selects the front camera,
  /// and initializes the camera controller with a high resolution preset.
  ///
  /// It also sets up a listener for workout counts to update the count
  /// and trigger the celebration overlay when the target count is reached.
  ///
  /// Returns a [Future] that completes when the camera is initialized.
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      ),
      ResolutionPreset.high,
    );
    await _controller?.initialize();

    // Listen for changes in workout counts to update the count and trigger announcements
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

  /// Starts the workout detection process.
  /// This method checks if the camera controller is initialized and not already streaming images.
  /// If the conditions are met, it starts the image stream and begins detecting workouts.
  ///
  /// Returns a [void] that completes when the detection starts.
  void _startDetecting() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) return;
      setState(() {
        _showStartButton = false;
      });

      _startTimer();
      // Start the camera image stream
      // This will call the detectWorkout method in WorkoutAnalyzer
      // with the input image from the camera
      _controller!.startImageStream((image) async {
        // Check if we are already detecting to avoid multiple detections
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

  /// Stops the workout detection process and starts a countdown for the celebration overlay.
  /// This method checks if the camera controller is initialized and streaming images.
  /// If so, it cancels the timer, stops the image stream,
  /// and sets a flag to show the celebration overlay.
  /// It also starts a countdown timer that updates the UI every second.
  ///
  /// Returns a [void] that completes when the detection is stopped.
  void _stopDetecting() async {
    if (_controller != null && _controller!.value.isStreamingImages) {
      // Stop the workout timer
      _workoutTimerService.stop();
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

  /// Navigates to the WorkoutProgressionPage with the current exercise index and difficulty.
  /// This method creates a new route and passes the necessary parameters,
  /// including the difficulty level, images, starting point, and character images.
  ///
  /// Returns a [void] that completes when the navigation is done.
  void _goToProgressionPage() {
    final Difficulty difficulty = widget.difficulty == "beginner"
        ? Difficulty.easy
        : widget.difficulty == "intermediate"
            ? Difficulty.medium
            : Difficulty.hard;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutProgressionPage(
          difficulty: difficulty,
          images: [
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['path']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['building']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.characterImages['tree']}",
            "${dotenv.env['SERVER_BASE_URL']}${widget.landmarkImageUrl}",
          ],
          startingPoint: widget.currentExerciseIndex,
          workoutSessionExercises: widget.workoutSessionExercises,
          currentExerciseIndex: widget.currentExerciseIndex + 1,
          characterImages: widget.characterImages,
          boxType: widget.boxType,
          city: widget.city,
          level: widget.level,
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
                  CelebrationOverlay(
                    finalTime: _elapsedTime,
                    city: widget.city,
                    level: widget.level,
                    characterImages: widget.characterImages,
                    difficulty: widget.difficulty,
                  ),
                if (_showCelebration && _celebrationCountdown > 0)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Text(
                      t.camera
                          .next_step_countdown(seconds: _celebrationCountdown),
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
                      child: Text(
                        t.camera.start_workout,
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
    _workoutTimerService.onTick = null;
    _workoutTimerService.stop();
    _celebrationTimer?.cancel();
    _workoutAnalyzer.dispose();
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        _controller!.stopImageStream();
      }
      _controller!.dispose();
    }
    _flutterTts.stop();
    super.dispose();
  }
}
