import 'dart:typed_data';
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'image_converter.dart';

class PoseDetector {
  late Interpreter _interpreter;

  final Map<String, int> keypointMap = {
    'nose': 0,
    'left_eye': 1,
    'right_eye': 2,
    'left_ear': 3,
    'right_ear': 4,
    'left_shoulder': 5,
    'right_shoulder': 6,
    'left_elbow': 7,
    'right_elbow': 8,
    'left_wrist': 9,
    'right_wrist': 10,
    'left_hip': 11,
    'right_hip': 12,
    'left_knee': 13,
    'right_knee': 14,
    'left_ankle': 15,
    'right_ankle': 16,
  };

  List<List<double>> keypoints = [];

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
        'assets/model/movenet-singlepose-lightning-tflite-float16.tflite');
  }

  Future<bool> runPoseDetection(CameraImage image) async {
    Stopwatch stopwatch = Stopwatch()..start();

    final inputBuffer = convertCameraImage(image);
    var outputShape = _interpreter.getOutputTensor(0).shape;
    var outputBuffer = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
        .reshape(outputShape);

    _interpreter.run(inputBuffer, outputBuffer);

    keypoints = outputBuffer[0][0];

    bool result = processKeypoints(keypoints);

    stopwatch.stop();
    // print("Inference Time: ${stopwatch.elapsedMilliseconds} ms");

    return result;
  }

  Uint8List convertCameraImage(CameraImage image) {
    img.Image convertedImage = ImageUtils.convertCameraImage(image);

    final img.Image resizedImage =
        img.copyResize(convertedImage, width: 192, height: 192);
    
    return resizedImage.getBytes(order: img.ChannelOrder.rgb);
  }

  bool processKeypoints(List<List<double>> _keypoints) {
    final leftKnee = _keypoints[keypointMap['left_knee'] ?? 0];
    final leftHip = _keypoints[keypointMap['left_hip'] ?? 0];
    final leftAnkle = _keypoints[keypointMap['left_ankle'] ?? 0];

    final rightKnee = _keypoints[keypointMap['right_knee'] ?? 0];
    final rightHip = _keypoints[keypointMap['right_hip'] ?? 0];
    final rightAnkle = _keypoints[keypointMap['right_ankle'] ?? 0];

    // print("Keypoints = $_keypoints");

    // Calculer les angles pour les deux jambes
    final double leftAngle = calculateAngle(leftKnee, leftHip, leftAnkle);
    final double rightAngle = calculateAngle(rightKnee, rightHip, rightAnkle);

    print("Left knee angle: $leftAngle");
    print("Right knee angle: $rightAngle");

    // Définir des seuils d'angles pour un squat valide
    final double minAngle = 90.0;
    final double maxAngle = 140.0;

    // Vérifier si les angles des deux genoux sont dans la plage d'un squat
    bool isSquatting = leftAngle >= minAngle && leftAngle <= maxAngle &&
                      rightAngle >= minAngle && rightAngle <= maxAngle;

    // Vérification si les hanches sont suffisamment basses (en fonction de la position verticale)
    final double hipHeightThreshold = 0.5; // Par exemple, si la hauteur des hanches par rapport aux genoux est faible
    final double leftHipHeight = leftHip[1];  // Utilisation de la coordonnée Y pour mesurer la hauteur
    final double rightHipHeight = rightHip[1];

    if (isSquatting) {
      print("Squat detected!");
      return true;
    }

    print("Not a squat.");
    return false;
  }

  double calculateAngle(List<double> a, List<double> b, List<double> c) {
    final ax = a[1], ay = a[0];
    final bx = b[1], by = b[0];
    final cx = c[1], cy = c[0];

    final baX = ax - bx, baY = ay - by;
    final bcX = cx - bx, bcY = cy - by;

    final dotProduct = baX * bcX + baY * bcY;
    final magnitudeBA = sqrt(baX * baX + baY * baY);
    final magnitudeBC = sqrt(bcX * bcX + bcY * bcY);

    if (magnitudeBA == 0 || magnitudeBC == 0) return 0.0;

    final angleRad = acos(dotProduct / (magnitudeBA * magnitudeBC));
    return angleRad * 180 / pi;
  }

}
