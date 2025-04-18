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
  final BoxType boxType;

  const CameraView({
    super.key,
    required this.workoutSessionExercises,
    required this.difficulty,
    required this.currentExerciseIndex,
    required this.landmarkImageUrl,
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

  int _count = 0;
  late int _targetCount;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();

    final exercise = widget.workoutSessionExercises[widget.difficulty]![
        widget.currentExerciseIndex];
    _workoutType = WorkoutType.values.firstWhere(
      (type) => type.toString().split('.').last == exercise['name'],
    );
    debugPrint('Workout type: $_workoutType');
    _targetCount = exercise['repetitions'];

    initCamera();
    _workoutAnalyzer.workoutCounts.addListener(() {
      final count = _workoutAnalyzer.workoutCounts.value[_workoutType];
      if (count != null && count > _count) {
        setState(() {
          _count = count;
          if (_count == _targetCount) {
            _showCelebration = true;
            _stopDetecting();
            _onRepsCompleted();
          }
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedTime += const Duration(seconds: 1);

        // Simulate incrementing the counter every 3 seconds
        if (_elapsedTime.inSeconds % 3 == 0 && _count < _targetCount) {
          _count++;
        }

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

    if (mounted) {
      setState(() {});
    }
  }

  void _startDetecting() {
    if (_controller != null) {
      _startTimer();
      _controller!.startImageStream((image) async {
        if (_isDetecting) return;
        _isDetecting = true;

        try {
          final inputImage = ImageUtils.getInputImage(image, _controller);
          await _workoutAnalyzer.detectWorkout(inputImage, _workoutType);
        } catch (e) {
          debugPrint('Error processing image: $e');
        } finally {
          _isDetecting = false;
        }
      });
    }
  }

  void _stopDetecting() {
    if (_controller != null) {
      _timer?.cancel();
      _controller!.stopImageStream();
    }
  }

  void _resetCount() {
    setState(() {
      _count = 0;
      _elapsedTime = Duration.zero;
      _showCelebration = false;
    });
  }

  void _onRepsCompleted() {
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
                  "assets/images/pebble_path.png",
                  "${dotenv.env['SERVER_BASE_URL']}/media/decorations/building.webp",
                  "${dotenv.env['SERVER_BASE_URL']}/media/decorations/tree.webp",
                  "${dotenv.env['SERVER_BASE_URL']}${widget.landmarkImageUrl}",
                ],
                startingPoint: widget.currentExerciseIndex,
                workoutSessionExercises: widget.workoutSessionExercises,
                currentExerciseIndex: widget.currentExerciseIndex + 1,
              )),
    ).then((_) {
      _resetCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF4FF),
      body: _controller != null && _controller!.value.isInitialized
          ? Stack(
              children: [
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
                  LeftBoxWidget(elapsedTime: _elapsedTime, count: _count),
                if (widget.boxType == BoxType.bottom)
                  BottomBoxWidget(elapsedTime: _elapsedTime, count: _count),

                // Overlay when count hits the target
                if (_showCelebration) const CelebrationOverlay(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutAnalyzer.dispose();
    _controller?.stopImageStream();
    _controller?.dispose();
    super.dispose();
  }
}
