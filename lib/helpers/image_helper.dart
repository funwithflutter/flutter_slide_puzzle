import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<ByteData> loadImageFromAssets(String imageAssetPath) {
  return rootBundle.load(imageAssetPath);
}

/// Resizes the images with a target heigh tand width.
///
/// This does not work on web: https://bugs.chromium.org/p/skia/issues/detail?id=11275
Future<ui.Image> resizeImage(
    ByteData assetImageByteData, int height, int width) async {
  final codec = await ui.instantiateImageCodec(
    assetImageByteData.buffer.asUint8List(),
    targetHeight: height,
    targetWidth: width,
  );
  final image = (await codec.getNextFrame()).image;
  return image;
}
