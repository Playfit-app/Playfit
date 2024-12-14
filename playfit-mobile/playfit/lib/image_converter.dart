import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;
import 'dart:typed_data';

/// ImageUtils
class ImageUtils {
  ///
  /// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
  ///
  static imglib.Image convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      throw Exception('Undefined image type: ${cameraImage.format.group}');
    }
  }

  ///
  /// Converts a [CameraImage] in BGRA888 format to [image_lib.Image] in RGB format
  ///

  static imglib.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    return imglib.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: imglib.ChannelOrder.bgra,
    );
  }

  ///
  /// Converts a [CameraImage] in YUV420 format to [image_lib.Image] in RGB format
  ///
  static imglib.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int imageWidth = cameraImage.width;
    final int imageHeight = cameraImage.height;

    final Uint8List yBuffer = cameraImage.planes[0].bytes;
    final Uint8List uBuffer = cameraImage.planes[1].bytes;
    final Uint8List vBuffer = cameraImage.planes[2].bytes;

    final int yRowStride = cameraImage.planes[0].bytesPerRow;
    final int yPixelStride = cameraImage.planes[0].bytesPerPixel!;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;

    final imglib.Image image = imglib.Image(width: imageWidth, height: imageHeight);

    for (int h = 0; h < imageHeight; h++) {
      for (int w = 0; w < imageWidth; w++) {
        final int yIndex = h * yRowStride + w * yPixelStride;

        final int uvIndex = 
            (h ~/ 2) * uvRowStride + (w ~/ 2) * uvPixelStride;

        final int y = yBuffer[yIndex];
        final int u = uBuffer[uvIndex] - 128;
        final int v = vBuffer[uvIndex] - 128;

        int r = (y + v * 1.402).round();
        int g = (y - u * 0.344 - v * 0.714).round();
        int b = (y + u * 1.772).round();

        image.setPixelRgb(w, h, r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255));
      }
    }

    return image;
  }

}