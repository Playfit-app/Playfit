import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class UIImageCacheManager {
  static final UIImageCacheManager _instance = UIImageCacheManager._internal();
  factory UIImageCacheManager() => _instance;
  UIImageCacheManager._internal();
  final Map<String, ui.Image> _imageCache = {};

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
}
