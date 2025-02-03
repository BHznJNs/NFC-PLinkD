import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_plinkd/pages/resource_view/image.dart';
import 'package:nfc_plinkd/pages/resource_view/audio.dart';
import 'package:nfc_plinkd/pages/resource_view/video.dart';
import 'package:nfc_plinkd/utils/media.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:url_launcher/url_launcher_string.dart';

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
  static const double size = 128;
  File? thumbnail;

  void openResource() {
    switch (widget.type) {
      case ResourceType.image:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ImagePage(widget.path)));
      case ResourceType.video:
        openVideoWithDefaultPlayer(context, widget.path);
      case ResourceType.audio:
        openAudioWithDefaultPlayer(context, widget.path);
      case ResourceType.webLink:
        launchUrlString(widget.path);
    }
  }

  Widget thumbnailBuilder() {
    if (thumbnail != null && (
      widget.type == ResourceType.image ||
      widget.type == ResourceType.video
    )) {
      return Stack(children: [
        Container(
          width: size - 16,
          height: size - 16,
          margin: EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(thumbnail!, fit: BoxFit.cover),
          ),
        ),
        if (widget.type == ResourceType.video)
          Container(
            width: size - 16,
            height: size - 16,
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.4), 
              borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            alignment: Alignment.center,
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
        child: Icon(
          Icons.audio_file,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    } else if (widget.type == ResourceType.webLink) {
      final faviconUri = Uri
        .parse(widget.path)
        .replace(path: 'favicon.ico');
      return Container(
        width: size - 16,
        height: size - 16,
        margin: EdgeInsets.all(8),
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            width: 72,
            height: 72,
            faviconUri.toString(),
            fit: BoxFit.contain,
          ),
        ),
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

    // load thumbnail
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
    final description = Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: widget.description != null
        ? Text(widget.description!, overflow: TextOverflow.ellipsis)
        : Opacity(opacity: .4, child: Text('No description')),
    );

    final draggableRegion = ReorderableDragStartListener(
      index: widget.index,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 48,
          height: double.infinity,
          alignment: Alignment.center,
          child: const Icon(Icons.drag_handle),
        ),
      ),
    );

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: size,
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
      ),
    );
  }
}
