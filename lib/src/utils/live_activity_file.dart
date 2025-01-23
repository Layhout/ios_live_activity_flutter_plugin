import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class LiveActivityImageFileOptions {
  final int resizeWidth;
  final int resizeHeight;

  LiveActivityImageFileOptions({
    required this.resizeWidth,
    required this.resizeHeight,
  });
}

class LiveActivityFile {
  final bool isAsset;
  final String path;
  final LiveActivityImageFileOptions? imageOption;

  LiveActivityFile(
      {required this.isAsset, required this.path, this.imageOption});

  factory LiveActivityFile.fromAsset(String path,
          {LiveActivityImageFileOptions? imageOption}) =>
      LiveActivityFile(isAsset: true, path: path, imageOption: imageOption);

  factory LiveActivityFile.fromUrl(String url,
          {LiveActivityImageFileOptions? imageOption}) =>
      LiveActivityFile(isAsset: false, path: url, imageOption: imageOption);

  Future<String> get base64String async {
    ByteData byteData;

    if (isAsset) {
      byteData = await rootBundle.load(path);
    } else {
      byteData = await NetworkAssetBundle(Uri.parse(path)).load('');
    }

    Uint8List fileBytes = byteData.buffer.asUint8List();

    if (imageOption != null) {
      fileBytes = await _compressAndResizeImage(fileBytes);
    }

    return base64Encode(fileBytes);
  }

  Future<Uint8List> _compressAndResizeImage(Uint8List bytes) async {
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Invalid image file");
    }

    final resizedImage = img.copyResize(image,
        width: imageOption!.resizeWidth, height: imageOption!.resizeHeight);

    final compressedBytes = img.encodeJpg(resizedImage, quality: 20);

    return compressedBytes;
  }

  static Future<void> prepareFiles(Map<String, dynamic> data) async {
    for (String k in data.keys) {
      final v = data[k];
      if (v is LiveActivityFile) {
        data[k] = await v.base64String;
      }
    }
  }
}
