import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<File?> generateImageThumbnail(List<dynamic> params) async {
  final rootIsolateToken = params[0] as RootIsolateToken?;
  final imagePath = params[1] as String;
  final size = params[2] as int;

  if (rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  final file = File(imagePath);
  final directory = await getTemporaryDirectory();
  final thumbnailPath = '${directory.path}/${path.basenameWithoutExtension(imagePath)}.jpeg';
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path, thumbnailPath,
    quality: 75,
    minWidth: size,
    minHeight: size,
  );
  if (result == null) return null;
  return File(result.path);
}

final videoThumbnail = FcNativeVideoThumbnail();
Future<File?> generateVideoThumbnail(List<dynamic> params) async {
  final rootIsolateToken = params[0] as RootIsolateToken?;
  final videoPath = params[1] as String;
  final size = params[2] as int;

  if (rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  final directory = await getTemporaryDirectory();
  final thumbnailPath = '${directory.path}/${path.basenameWithoutExtension(videoPath)}.jpeg';
  try {
    final thumbnailGenerated = await videoThumbnail.getVideoThumbnail(
      srcFile: videoPath,
      destFile: thumbnailPath,
      width: size,
      height: size,
      format: 'jpeg',
      quality: 75,
    );
    if (!thumbnailGenerated) return null;
  } catch(_) {
    return null;
  }
  return File(thumbnailPath);
}
