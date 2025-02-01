import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
// import 'package:chewie/chewie.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_video_controls/universal_video_controls.dart';
import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:nfc_plinkd/db.dart';

class ResourceListView extends StatelessWidget {
  const ResourceListView(this.resourceList, {super.key});

  final List<ResourceModel> resourceList;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
      onReorder: (oldIndex, newIndex) {
        // 
      },
      itemCount: resourceList.length,
      itemBuilder: (context, index) {
        final resource = resourceList[index];
        return _GenericResourceItem(
          key: ValueKey(index),
          path: resource.path,
          type: resource.type,
        );
      },
    );
  }
}

class _GenericResourceItem extends StatelessWidget {
  const _GenericResourceItem({
    super.key,
    required this.path,
    required this.type,
  });

  final String path;
  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ResourceType.image => _ImageItem(path),
      ResourceType.video => _VideoItem(path),
      ResourceType.audio => _AudioItem(path),
      ResourceType.webLink => _WebLinkItem(path),
    };
  }
}

class _ImageItem extends StatelessWidget {
  const _ImageItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      )
    );
  }
}

class _VideoItem extends StatefulWidget {
  const _VideoItem(this.path);

  final String path;

  @override
  State<_VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<_VideoItem> {
  late VideoPlayerController controller;
  bool isInitialized = false;
  // late final player = Player();
  // late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.path));
    controller.initialize().then((_) {
      setState(() => isInitialized = true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          title: Text('Video: ${basename(widget.path)}'),
          onExpansionChanged: (isExpanded) {
            // 
          },
          children: [
            isInitialized
              ? AspectRatio(
                  aspectRatio: 1/ controller.value.aspectRatio,
                  child: VideoControls(
                    player: VideoPlayerControlsWrapper(controller),
                  ),
                )
              : const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}

// class _VideoItem extends StatefulWidget {
//   const _VideoItem(this.path);

//   final String path;

//   @override
//   State<StatefulWidget> createState() => _VideoItemState();
// }
// class _VideoItemState extends State<_VideoItem> {
//   VideoPlayerController? videoPlayerController;
//   // double? _aspectRatio;
//   ChewieController? chewieController;

//   Future<void> initializePlayer() async {
//     videoPlayerController = VideoPlayerController.file(File(widget.path));
//     await videoPlayerController!.initialize();
//     setState(() {
//       // _aspectRatio = videoPlayerController!.value.aspectRatio;
//       // print('_aspectRatio: $_aspectRatio');
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         showOptions: false,
//       );
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     initializePlayer();
//   }

//   @override
//   void dispose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ableToPlay = chewieController != null && chewieController!.videoPlayerController.value.isInitialized;
//     return Card(
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: ableToPlay
//           ?
//           SizedBox(width: 300, child: Chewie(controller: chewieController!))
//           // FittedBox(
//           //   fit: BoxFit.cover,
//           //   child: SizedBox(
//           //     width: MediaQuery.of(context).size.width,
//           //     child: Chewie(controller: chewieController!),
//           //   ),
//           // )
//           // AspectRatio(
//           //   aspectRatio: _aspectRatio!,
//           //   child: Chewie(
//           //     controller: chewieController!,
//           //   ),
//           // )
//           : Center(
//             child: SizedBox(
//               height: 40,
//               child: CircularProgressIndicator.adaptive(),
//             ),
//           ),
//       ),
//     );
//   }
// }

class _AudioItem extends StatelessWidget {
  const _AudioItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _WebLinkItem extends StatelessWidget {
  const _WebLinkItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
