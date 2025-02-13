import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';
import 'package:nfc_plinkd/config.dart';

Future<void> openVideoWithDefaultPlayer(BuildContext context, String path) async {
  final result = await OpenFile.open(path);
  final useBuiltinVideoPlayer = await Configuration.useBuiltinVideoPlayer.read();
  if ((useBuiltinVideoPlayer ?? false) && context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => VideoPlayerPage(path)));
    return;
  }

  switch (result.type) {
    case ResultType.done: return;
    case ResultType.fileNotFound:
      if (kDebugMode) print('Target file not found: $path');
    case ResultType.noAppToOpen:
    case ResultType.permissionDenied:
    case ResultType.error:
      // fallback to build-in player
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => VideoPlayerPage(path)));
      }
  }
}

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage(this.path, {super.key});

  final String path;

  @override
  State<StatefulWidget> createState() => _VideoPageState();
}
class _VideoPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;
  bool isInitialized = false;
  late Orientation orientation;

  void share() {
    Share.shareXFiles([XFile(widget.path)]);
  }

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.path));
    controller.initialize().then((_) =>
      setState(() => isInitialized = true)
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: isInitialized ? share : null,
          icon: Icon(Icons.share),
        )
      ]),
      body: isInitialized
        ? VideoControls(
            player: VideoPlayerControlsWrapper(controller),
            filterQuality: FilterQuality.medium,
          )
        : const CircularProgressIndicator.adaptive(),
    );
  }
}
