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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.timer, color: Colors.orange),
                            SizedBox(width: 5),
                            Text(
                              '0:30',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.fitness_center, color: Colors.orange),
                            SizedBox(width: 5),
                            Text(
                              '1',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 50,
                          child: Image.asset("assets/images/mascot.png"),
                        ),
                      ],
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
