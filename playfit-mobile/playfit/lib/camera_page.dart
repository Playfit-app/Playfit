import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'movenet_model.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  final PoseDetector model = PoseDetector();
  var squatCount = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
    model.loadModel();
  }

  // Initialize the camera
  Future<void> initCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    await _controller.initialize();

    // Start the image stream to process frames
    _controller.startImageStream((image) async {
      // Convert the image to a format suitable for the model (e.g., 640x640). Every 2 seconds, the model will run inference on the image.
      if (DateTime.now().second % 2 == 0) {
          bool result = await model.runPoseDetection(image);
          if (result) {
            // If the model detects a squat, increment the squat count
            squatCount++;
            print('Squat count: $squatCount');
          }
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Estimation'),
      ),
      body: _controller.value.isInitialized
          ? CameraPreview(
            _controller,
          )  // Display camera feed
          : Center(child: CircularProgressIndicator()),
    );
  }
}
