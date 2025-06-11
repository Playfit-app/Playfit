import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class ImageUtils {
  /// Converts a [CameraImage] to an [InputImage] for use with ML Kit pose detection.
  /// This method handles the conversion of the camera image format and applies the necessary metadata.
  /// 
  /// `image` is the camera image to be converted.
  /// `controller` is the camera controller used to determine the sensor orientation.
  /// 
  /// Returns an [InputImage] that can be used for pose detection.
  static InputImage getInputImage(
      CameraImage image, CameraController? controller) {
    final WriteBuffer allBytes = WriteBuffer();

    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    // Dynamically determine rotation based on device orientation
    final cameraRotation = controller!.description.sensorOrientation;
    final InputImageRotation imageRotation;
    switch (cameraRotation) {
      case 90:
        imageRotation = InputImageRotation.rotation90deg;
        break;
      case 180:
        imageRotation = InputImageRotation.rotation180deg;
        break;
      case 270:
        imageRotation = InputImageRotation.rotation270deg;
        break;
      case 0:
      default:
        imageRotation = InputImageRotation.rotation0deg;
        break;
    }

    final InputImageFormat inputImageFormat =
        defaultTargetPlatform == TargetPlatform.android
            ? InputImageFormat.nv21
            : InputImageFormat.bgra8888;

    final metaData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metaData);
  }
}
