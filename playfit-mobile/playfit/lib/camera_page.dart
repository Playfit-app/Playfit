import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:playfit/workout_analyzer.dart';
import 'package:playfit/image_converter.dart';
import 'package:playfit/components/camera/left_box_widget.dart';
import 'package:playfit/components/camera/bottom_box_widget.dart';
import 'package:playfit/components/camera/celebration_overlay.dart'; // New widget

enum BoxType { left, bottom }

class CameraView extends StatefulWidget {
  final BoxType boxType;

  const CameraView({super.key, required this.boxType});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isDetecting = false;
  final WorkoutAnalyzer _workoutAnalyzer = WorkoutAnalyzer();
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

  int _count = 0; // Your current count
  final int _targetCount = 5; // Change this to your target
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    startTimer();
  }

  void startTimer() {
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

    _controller?.startImageStream((image) async {
      if (_isDetecting) return;

      _isDetecting = true;
      try {
        final inputImage = ImageUtils.getInputImage(image, _controller);
        await _workoutAnalyzer.detectWorkout(inputImage, WorkoutType.squat);
      } catch (e) {
        debugPrint('Error processing image: $e');
      } finally {
        _isDetecting = false;
      }
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
                if (_showCelebration)
                  const CelebrationOverlay(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutAnalyzer.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
