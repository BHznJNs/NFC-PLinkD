import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_plinkd/pages/resource_view/image.dart';
import 'package:nfc_plinkd/utils/media.dart';
// import 'package:path/path.dart' as path;
// import 'package:video_player/video_player.dart';
// import 'package:universal_video_controls/universal_video_controls.dart';
// import 'package:universal_video_controls_video_player/universal_video_controls_video_player.dart';
import 'package:nfc_plinkd/db.dart';

class ResourceListView extends StatefulWidget {
  const ResourceListView(this.resourceList, {super.key});

  final List<ResourceModel> resourceList;

  @override
  State<StatefulWidget> createState() => _ResourceListViewState();
}

class _ResourceListViewState extends State<ResourceListView> {
  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return child;
  }

  @override
  Widget build(BuildContext context) {  
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      proxyDecorator: proxyDecorator,
      padding: const EdgeInsets.only(
        left: 24, right: 24,
        top: 12, bottom: 96,
      ),
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;
        setState(() {
          final item = widget.resourceList.removeAt(oldIndex);
          widget.resourceList.insert(newIndex, item);
        });
      },
      itemCount: widget.resourceList.length,
      itemBuilder: (context, index) {
        final item = widget.resourceList[index];
        return _GenericResourceItem(
          key: Key(item.path),
          index: index,
          path: item.path,
          type: item.type,
          description: item.description,
        );
      },
    );
  }
}

class _GenericResourceItem extends StatefulWidget {
  const _GenericResourceItem({
    super.key,
    required this.path,
    required this.type,
    required this.index,
    required this.description,
  });

  final String path;
  final ResourceType type;
  final int index;
  final String? description;

  @override
  State<StatefulWidget> createState() => _GenericResourceItemState();
}
class _GenericResourceItemState extends State<_GenericResourceItem> {
  static const double size = 108;
  File? thumbnail;

  void openResource() {
    switch (widget.type) {
      case ResourceType.image:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ImagePage(widget.path)));
      case ResourceType.video:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ResourceType.audio:
        // TODO: Handle this case.
        throw UnimplementedError();
      case ResourceType.webLink:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  Widget thumbnailBuilder() {
    if (thumbnail != null && (
      widget.type == ResourceType.image ||
      widget.type == ResourceType.video
    )) {
      return Stack(children: [
        Ink.image(
          image: FileImage(thumbnail!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        if (widget.type == ResourceType.video)
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            color: Color.fromRGBO(0, 0, 0, 0.4), 
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
      ]);
    } else if (widget.type == ResourceType.audio) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: const Icon(Icons.audio_file, size: 64),
      );
    } else if (widget.type == ResourceType.webLink) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: const Icon(Icons.link, size: 64),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CircularProgressIndicator.adaptive(),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.type == ResourceType.image || widget.type == ResourceType.video) {
      final generator = switch (widget.type) {
        ResourceType.image => generateImageThumbnail,
        ResourceType.video => generateVideoThumbnail,
        ResourceType.audio => throw UnimplementedError(),
        ResourceType.webLink => throw UnimplementedError(),
      };
      final rootIsolateToken = RootIsolateToken.instance;
      (rootIsolateToken == null
        ? generator([null, widget.path, size.toInt()]) // fallback to block computation
        : compute(generator, [rootIsolateToken, widget.path, size.toInt()])
      ).then((thumbnail_) {
        if (thumbnail_ == null) return;
        setState(() => thumbnail = thumbnail_);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = widget.description != null
      ? Text(widget.description!)
      : Opacity(opacity: .4, child: Text('No description'));

    final draggableRegion = ReorderableDragStartListener(
      index: widget.index,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 48,
          height: size,
          alignment: Alignment.center,
          child: const Icon(Icons.drag_handle),
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(child: InkWell(
            onTap: openResource,
            child: Row(children: [
              thumbnailBuilder(),
              Expanded(child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: description,
              )),
            ]),
          )),
          draggableRegion,
        ],
      ),
    );
  }
}
