import 'dart:async';
import 'dart:io';

import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nfc_plinkd/components/audio.dart';
import 'package:nfc_plinkd/db.dart';

final picker = ImagePicker();

typedef ResourcePicker = Future<ResourcePickerResult> Function(BuildContext);
typedef ResourcePickerResult = List<(XFile, ResourceType)>;

ResourceType? getResourceTypeFromExtname(String extname) {
  switch (extname) {
    case "jpeg": case "jpg":
    case "tiff": case "tif":
    case "webp":
    case "indd":
    case "png":
    case "gif":
    case "ico":
    case "svg":
    case "eps":
    case "psd":
    case "raw":
      return ResourceType.image;

    case "rmvb": case "rm":
    case "avchd":
    case "avi":
    case "mov":
    case "mp4":
    case "flv":
    case "wmv":
    case "asf":
    case "asx":
    case "3gp":
    case "mkv":
    case "dat":
      return ResourceType.video;

    case "aiff": case "aif":
    case "midi": case "mid":
    case "flac":
    case "ogg":
    case "cda":
    case "wav":
    case "mp3":
    case "m4a":
    case "wma":
    case "ra":
    case "vqf":
    case "ape":
      return ResourceType.audio;
  }
  return null;
}

Future<ResourcePickerResult> takePhoto(BuildContext _) async {
  final photo = await picker.pickImage(source: ImageSource.camera);
  if (photo == null) return [];
  return [(photo, ResourceType.image)];
}

Future<ResourcePickerResult> recordVideo(BuildContext _) async {
  final video = await picker.pickVideo(source: ImageSource.camera);
  if (video == null) return [];
  return [(video, ResourceType.video)];
}

Future<ResourcePickerResult> recordAudio(BuildContext context) async {
  final completer = Completer<ResourcePickerResult>();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
    Recorder(onRecordEnd: (recordedFilePath) {
      if (recordedFilePath == null) completer.complete([]);
      completer.complete([(XFile(recordedFilePath!), ResourceType.audio)]);
    })
  ));
  return completer.future;
}

Future<ResourcePickerResult> pickMediaFile(BuildContext _) async {
  FilePickerResult? result = await FilePicker
    .platform
    .pickFiles(
      type: FileType.media,
      allowMultiple: true);
  if (result == null) return [];
  final ResourcePickerResult resultList = [];
  for (final file in result.files) {
    if (file.extension == null || file.path == null) {
      continue;
    }
    final fileType = getResourceTypeFromExtname(file.extension!);
    if (fileType == null) {
      continue;
    }
    resultList.add((XFile(file.path!), fileType));
  }
  return resultList;
}

Future<File?> generateImageThumbnail(List<dynamic> params) async {
  final rootIsolateToken = params[0] as RootIsolateToken?;
  final imagePath = params[1] as String;
  final thumbSize = params[2] as int;

  if (rootIsolateToken != null) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
  }

  final File imageFile = File(imagePath);
  final List<int> imageBytes = await imageFile.readAsBytes();

  final img.Image? image = img.decodeImage(Uint8List.fromList(imageBytes));
  if (image == null) return null;

  final int size = image.width < image.height ? image.width : image.height;
  final int x = (image.width - size) ~/ 2;
  final int y = (image.height - size) ~/ 2;

  final img.Image thumbnail = img.copyCrop(image,
    x: x, y: y,
    width: size, height: size,
  );
  final img.Image resizedThumbnail = img.copyResize(thumbnail,
    width: thumbSize,
    height: thumbSize,
  );

  final directory = await getTemporaryDirectory();
  final thumbnailPath = '${directory.path}/${path.basenameWithoutExtension(imagePath)}.png';
  final encoded = img.encodePng(resizedThumbnail);
  File outputFile = File(thumbnailPath)..writeAsBytesSync(encoded);

  return outputFile;
}

final videoThumbnail = FcNativeVideoThumbnail();
Future<File?> generateVideoThumbnail(List<dynamic> params) async {
  final rootIsolateToken = params[0] as RootIsolateToken?;
  final videoPath = params[0] as String;
  final size = params[1] as int;

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
      quality: 60,
    );
    if (!thumbnailGenerated) return null;
  } catch(_) {
    return null;
  }
  return File(thumbnailPath);
}
