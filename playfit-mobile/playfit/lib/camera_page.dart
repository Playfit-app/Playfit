import 'dart:async';
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
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;

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

                /*
                // Nouvelle BOX à gauche, centrée verticalement, collée à l'écran
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 85,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    margin: const EdgeInsets.only(left: 0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.timer, color: Colors.orange, size: 36),
                            const SizedBox(height: 8),
                            Text(
                               '${_elapsedTime.inMinutes}:${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                               style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Column(
                          children: [
                            Icon(Icons.fitness_center,
                                color: Colors.orange, size: 36),
                            SizedBox(height: 8),
                            Text(
                              '1',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(
                          height: 100,
                          child: Image(
                            image: AssetImage("assets/images/mascot.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                */
                // Ancienne BOX en bas (désactivée via commentaire)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.orange, size: 30),
                            const SizedBox(width: 5),
                            Text(
                              '${_elapsedTime.inMinutes}:${(_elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Icon(Icons.fitness_center, color: Colors.orange, size: 30),
                            SizedBox(width: 5),
                            Text(
                              '1',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 80,
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
    _timer?.cancel();
    _workoutAnalyzer.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
