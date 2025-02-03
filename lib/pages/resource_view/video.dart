import 'dart:io';

import 'package:flutter/material.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

Future<void> openVideoWithDefaultPlayer(BuildContext context, String path) async {
  final result = await OpenFile.open(path);
  switch (result.type) {
    case ResultType.done: return;
    case ResultType.fileNotFound:
      // TODO: Handle this case.
      throw UnimplementedError();
    case ResultType.noAppToOpen:
    case ResultType.permissionDenied:
    case ResultType.error:
      // fallback to build-in player
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => VideoPlayerPage(path)));
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
      appBar: AppBar(),
      body: isInitialized
        ? VideoControls(
            player: VideoPlayerControlsWrapper(controller),
            filterQuality: FilterQuality.medium,
          )
        : const CircularProgressIndicator(),
    );
  }
}
