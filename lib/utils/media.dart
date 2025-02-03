import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nfc_plinkd/components/audio.dart';
import 'package:nfc_plinkd/db.dart';

final picker = ImagePicker();

typedef ResourcePicker = Future<ResourcePickerResult> Function(BuildContext);
typedef ResourcePickerResult = List<(String, ResourceType)>;

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
  return [(photo.path, ResourceType.image)];
}

Future<ResourcePickerResult> recordVideo(BuildContext _) async {
  final video = await picker.pickVideo(source: ImageSource.camera);
  if (video == null) return [];
  return [(video.path, ResourceType.video)];
}

Future<ResourcePickerResult> recordAudio(BuildContext context) async {
  final completer = Completer<ResourcePickerResult>();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
    Recorder(onRecordEnd: (recordedFilePath) {
      if (recordedFilePath == null) completer.complete([]);
      completer.complete([(recordedFilePath!, ResourceType.audio)]);
    })
  ));
  return completer.future;
}

Future<ResourcePickerResult> inputWebLink(BuildContext context) async {
  final result = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return WebLinkInputDialog();
    },
  );
  if (result == null) return [];
  return [(result, ResourceType.webLink)];
}
class WebLinkInputDialog extends StatefulWidget {
  const WebLinkInputDialog({super.key});

  @override
  State<StatefulWidget> createState() => WebLinkInputDialogState();
}
class WebLinkInputDialogState extends State<WebLinkInputDialog> {
  final TextEditingController controller = TextEditingController();
  bool _isTextFieldEmpty = true;
  String? _errorMessage;

  void _pasteText() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null) {
      controller.text = data.text ?? '';
    }
  }
  void _clearText() {
    controller.clear();
  }
  void _onTextChanged() {
    setState(() => _isTextFieldEmpty = controller.text.isEmpty);
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onTextChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      maxLines: 1,
      autofocus: true,
      controller: controller,
      decoration: InputDecoration(
        errorText: _errorMessage,
        suffixIcon: _isTextFieldEmpty
          ? IconButton(
              onPressed: _pasteText,
              icon: const Icon(Icons.paste),
            )
          : IconButton(
              onPressed: _clearText,
              icon: const Icon(Icons.clear),
            ),
      ),
    );
    final cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(null),
      child: Text('Cancel'),
    );
    final confirmButton = TextButton(
      onPressed: _isTextFieldEmpty ? null : () {
        final uri = Uri.tryParse(controller.text);
        final isValidUri = uri != null
          && uri.scheme.isNotEmpty
          && uri.host.isNotEmpty;
        if (isValidUri) {
          Navigator.of(context).pop(controller.text);
        } else {
          setState(() => _errorMessage = "Invalid URL");
        }
      },
      child: Text('Confirm'),
    );
    return AlertDialog.adaptive(
      title: Text('Website Link'),
      content: textField,
      actions: [
        cancelButton,
        confirmButton,
      ],
    );
  }
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
    resultList.add((file.path!, fileType));
  }
  return resultList;
}

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

const videoUtilChannel = MethodChannel('org.nfc_plinkd.bhznjns/video_util');
Future<int?> getVideoRotation(String videoPath) async {
  try {
    final int rotation = await videoUtilChannel.invokeMethod('getVideoRotation', {
      'videoPath': videoPath,
    });
    return rotation;
  } on PlatformException catch (_) {
    return null;
  }
}
