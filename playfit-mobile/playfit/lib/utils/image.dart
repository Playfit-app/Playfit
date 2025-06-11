import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class UIImageCacheManager {
  static final UIImageCacheManager _instance = UIImageCacheManager._internal();
  factory UIImageCacheManager() => _instance;
  UIImageCacheManager._internal();
  final Map<String, ui.Image> _imageCache = {};

  /// Loads an image from the assets or network and caches it.
  /// If the image is already cached, it returns the cached image.
  /// 
  /// `imagePath` is the path to the image in assets or a URL for network images.
  /// 
  /// Returns a [Future] that completes with the loaded [ui.Image].
  Future<ui.Image> loadImageFromAssets(String imagePath) async {
    if (_imageCache.containsKey(imagePath)) return _imageCache[imagePath]!;

    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List bytes = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      _imageCache[imagePath] = img;
      completer.complete(img);
    });
    return completer.future;
  }

  /// Loads an image from the network and caches it.
  /// If the image is already cached, it returns the cached image.
  /// 
  /// `imageUrl` is the URL of the image to be loaded.
  /// 
  /// Returns a [Future] that completes with the loaded [ui.Image].
  Future<ui.Image> loadImageFromNetwork(String imageUrl) async {
    if (_imageCache.containsKey(imageUrl)) return _imageCache[imageUrl]!;

    final ByteData data =
        await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
    final Uint8List bytes = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      _imageCache[imageUrl] = img;
      completer.complete(img);
    });
    return completer.future;
  }

  /// Loads an image from either assets or network based on the provided path.
  ///
  /// `image` is the path to the image in assets or a URL for network images.
  /// 
  /// Returns a [Future] that completes with the loaded [ui.Image].
  Future<ui.Image> loadImage(String image) async {
    if (image.startsWith('http')) {
      return await loadImageFromNetwork(image);
    } else {
      return await loadImageFromAssets(image);
    }
  }

  /// Clears the image cache.
  /// /// This method removes all cached images from memory.
  /// It can be useful to free up memory or when the images are no longer needed.
  void clearCache() {
    _imageCache.clear();
  }
}
