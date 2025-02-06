import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/pages/resource_view/image.dart';
import 'package:nfc_plinkd/pages/resource_view/audio.dart';
import 'package:nfc_plinkd/pages/resource_view/video.dart';
import 'package:nfc_plinkd/utils/media/thumbnail.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ResourceListView extends StatefulWidget {
  const ResourceListView(this.children, {super.key});

  final List<ResourceModel> children;

  @override
  State<StatefulWidget> createState() => _ResourceListViewState();
}

class _ResourceListViewState extends State<ResourceListView> {
  late List<ResourceModel> resources = widget.children;

  void modifyItem(int index, {
    String? path,
    String? description,
  }) {
    if (path != null) {
      resources[index] = resources[index].copyWith(path: path);
    }
    if (description != null) {
      resources[index] = resources[index].copyWith(description: description);
    }
    setState(() {});
  }

  void deleteItem(int index) {
    setState(() {
      resources.removeAt(index);
    });
  }

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
          final item = resources.removeAt(oldIndex);
          resources.insert(newIndex, item);
        });
      },
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final item = resources[index];
        return _GenericResourceItem(
          key: ObjectKey(item),
          index: index,
          path: item.path,
          type: item.type,
          description: item.description,
          onSave: modifyItem,
          onDelete: deleteItem,
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
    required this.onSave,
    required this.onDelete,
  });

  final String path;
  final ResourceType type;
  final int index;
  final String description;
  final Function(int, {String? path, String? description}) onSave;
  final Function(int) onDelete;

  @override
  State<StatefulWidget> createState() => _GenericResourceItemState();
}
class _GenericResourceItemState extends State<_GenericResourceItem> {
  static const double size = 128;
  File? thumbnail;

  late TextEditingController urlController = TextEditingController(text: widget.path);
  late TextEditingController descriptionController = TextEditingController(text: widget.description);

  void openResource() {
    switch (widget.type) {
      case ResourceType.image:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ImagePage(widget.path)));
        break;
      case ResourceType.video:
        openVideoWithDefaultPlayer(context, widget.path);
        break;
      case ResourceType.audio:
        openAudioWithDefaultPlayer(context, widget.path);
        break;
      case ResourceType.webLink:
        launchUrlString(widget.path);
        break;
    }
  }

  void openDialog() {
    // reset TextEditingControllers
    urlController = TextEditingController(text: widget.path);
    descriptionController = TextEditingController(text: widget.description);

    final deleteButton = TextButton(
      onPressed: () {
        widget.onDelete(widget.index);
        Navigator.of(context).pop();
      },
      child: Text('Delete', style: TextStyle(
        color: Theme.of(context).colorScheme.error
      )),
    );
    final saveButton = TextButton(
      onPressed: () {
        widget.onSave(widget.index,
          path: widget.type == ResourceType.webLink
            ? urlController.text
            : null,
          description: descriptionController.text,
        );
        Navigator.of(context).pop();
        setState(() {});
      },
      child: const Text('Save'),
    );
    final dialog = AlertDialog.adaptive(
      title: Text('Edit Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.type == ResourceType.webLink)
            ...[
              UrlTextField(urlController),
              SizedBox(height: 32),
            ],
          TextField(
            minLines: 1,
            maxLines: 3,
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'Input the descriptions here...',
            ),
          ),
        ],
      ),
      actions: [
        deleteButton,
        saveButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  Widget thumbnailBuilder() {
    if (thumbnail != null && (
      widget.type == ResourceType.image ||
      widget.type == ResourceType.video
    )) {
      final videoThumbnailMask = Container(
        width: size - 16,
        height: size - 16,
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.4), 
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      );
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
          videoThumbnailMask,
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
            errorBuilder: (context, object, stackTrace) {
              return Icon(Icons.link, size: 72);
            },
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
        ResourceType.audio || ResourceType.webLink => null,
      };
      if (generator == null) return;
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
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: widget.description.isNotEmpty
        ? Text(widget.description, overflow: TextOverflow.ellipsis)
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
              onLongPress: openDialog,
              child: Row(children: [
                thumbnailBuilder(),
                Expanded(child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
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
