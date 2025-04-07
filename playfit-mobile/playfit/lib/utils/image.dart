import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
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
}
