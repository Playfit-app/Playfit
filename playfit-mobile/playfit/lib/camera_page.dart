import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:playfit/workout_analyzer.dart';
import 'package:playfit/image_converter.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController? _controller;
  bool _isDetecting = false;
  final WorkoutAnalyzer _workoutAnalyzer = WorkoutAnalyzer();

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    await _controller?.initialize();

    if (mounted) {
      setState(() {});
    }

    _controller?.startImageStream((image) async {
      if (_isDetecting) {
        return;
      }

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
      appBar: AppBar(
        title: const Text('Pose Estimation'),
      ),
      body: _controller != null && _controller!.value.isInitialized
          ? Column(
              children: [
                // Camera preview taking half of the screen
                Expanded(
                  flex: 1,
                  child: CameraPreview(_controller!),
                ),
                // Workout count and additional UI
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ValueListenableBuilder<Map<WorkoutType, int>>(
                        valueListenable: _workoutAnalyzer.workoutCounts,
                        builder: (context, workoutCounts, child) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Squat Count: ${workoutCounts[WorkoutType.squat] ?? 0}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  // Add functionality here
                                },
                                child: const Text('Analyze Again'),
                              ),
                            ],
                          );
                        },
                      ),
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
    _workoutAnalyzer.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
