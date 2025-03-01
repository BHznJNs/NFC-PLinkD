import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:nfc_plinkd/components/custom_textfield.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/models.dart';
import 'package:nfc_plinkd/pages/resource_view/image.dart';
import 'package:nfc_plinkd/pages/resource_view/audio.dart';
import 'package:nfc_plinkd/pages/resource_view/video.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/media/thumbnail.dart';
import 'package:nfc_plinkd/utils/open_uri.dart';

class ResourceListView extends StatefulWidget {
  const ResourceListView(this.id, this.children, {super.key});

  final String id;
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

  void deleteItem(int index) async {
    final basePath = await getBasePath(widget.id);
    final resourcePath = path.join(basePath, resources[index].path);
    final resourceFile = File(resourcePath);
    if (await resourceFile.exists()) await resourceFile.delete();
    setState(() => resources.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    Widget proxyDecorator(Widget child, int index, Animation<double> animation) => child;

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
    this.description,
    required this.path,
    required this.type,
    required this.index,
    required this.onSave,
    required this.onDelete,
  });

  final String path;
  final ResourceType type;
  final int index;
  final String? description;
  final Function(int, {String? path, String? description}) onSave;
  final Function(int) onDelete;

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
        openWebLink(widget.path);
      case ResourceType.note:
        tryOpenNote(context, widget.path);
    }
  }

  Future<void> openEditingDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => _ResourceEditingDialog(
        index: widget.index,
        path: widget.path,
        type: widget.type,
        description: widget.description,
      )
    ) as _ResourceEditingResult?;
    if (result == null) return;
    if (result.path == null && result.description == null) {
      widget.onDelete(result.index);
      return;
    }
    widget.onSave(widget.index,
      path: [ResourceType.webLink, ResourceType.note]
        .contains(widget.type)
          ? result.path : null,
      description: result.description,
    );
  }

  Widget thumbnailBuilder() {
    Widget thumbnailContainerBuilder({required Widget child,}) => Container(
      width: size - 16,
      height: size - 16,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );

    final loadingThumbnail = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CircularProgressIndicator.adaptive(),
    );
    final videoThumbnailMask = thumbnailContainerBuilder(
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 32,
      ),
    );
    switch (widget.type) {
      case ResourceType.image when thumbnail != null:
      case ResourceType.video when thumbnail != null:
        return Stack(children: [
          thumbnailContainerBuilder(
            child: Image.file(thumbnail!, fit: BoxFit.cover)
          ),
          if (widget.type == ResourceType.video)
            videoThumbnailMask,
        ]);
      case ResourceType.audio:
        return thumbnailContainerBuilder(
          child: Icon(
            Icons.audio_file,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      case ResourceType.webLink:
        final faviconUri = Uri
          .parse(widget.path)
          .replace(path: 'favicon.ico');
        return thumbnailContainerBuilder(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Image.network(
              faviconUri.toString(),
              fit: BoxFit.contain,
              errorBuilder: (context, object, stackTrace) {
                return Icon(Icons.link, size: size - 16 - 40);
              },
            ),
          ),
        );
      case ResourceType.note:
        final uri = Uri.parse(widget.path);
        final image = Image.asset('assets/images/${uri.scheme}-icon.png');
        return thumbnailContainerBuilder(child: image);
      default: return loadingThumbnail;
    }
  }

  @override
  void initState() {
    super.initState();

    // load thumbnail
    if (widget.type == ResourceType.image || widget.type == ResourceType.video) {
      final generator = switch (widget.type) {
        ResourceType.image => generateImageThumbnail,
        ResourceType.video => generateVideoThumbnail,
        ResourceType.audio || ResourceType.webLink || ResourceType.note => null,
      };
      if (generator == null) return;
      final rootIsolateToken = RootIsolateToken.instance;
      (rootIsolateToken == null
        ? generator([null, widget.path, (size - 16).toInt()]) // fallback to block computation
        : compute(generator, [rootIsolateToken, widget.path, (size - 16).toInt()])
      ).then((thumbnail_) {
        if (thumbnail_ == null) return;
        setState(() => thumbnail = thumbnail_);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final description = Container(
      height: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: widget.description != null && widget.description!.isNotEmpty
        ? Text(widget.description!, overflow: TextOverflow.ellipsis)
        : Opacity(
          opacity: .4,
          child: Text(l10n.resourceList_item_noDescription_hint),
        ),
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
              onLongPress: openEditingDialog,
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

class _ResourceEditingResult {
  const _ResourceEditingResult(this.index, {this.path, this.description});
  final int index;
  final String? path;
  final String? description;
}
class _ResourceEditingDialog extends StatefulWidget {
  const _ResourceEditingDialog({
    required this.index,
    required this.path,
    required this.type,
    this.description,
  });

  final int index;
  final String path;
  final ResourceType type;
  final String? description;

  @override
  State<StatefulWidget> createState() => _ResourceEditingDialogState();
}
class _ResourceEditingDialogState extends State<_ResourceEditingDialog> {
  late TextEditingController urlController = TextEditingController(text: widget.path);
  late TextEditingController descriptionController = TextEditingController(text: widget.description);
  late bool isNeededToEditPath = [ResourceType.webLink, ResourceType.note].contains(widget.type);
  String? errorText;

  void onDelete() {
    Navigator.of(context).pop(_ResourceEditingResult(widget.index));
  }

  void onSave() {
    if (isNeededToEditPath && !isValidUri(urlController.text)) {
      final l10n = S.of(context)!;
      setState(() =>
        errorText = l10n.general_invalidUrlMsg);
      return;
    }
    final res = _ResourceEditingResult(
      widget.index,
      path: isNeededToEditPath
        ? urlController.text
        : null,
      description: descriptionController.text,
    );
    Navigator.of(context).pop(res);
  }

  @override
  void dispose() {
    urlController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final deleteButton = TextButton(
      onPressed: onDelete,
      child: Text(l10n.editLinkPage_dialogAction_delete,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error
        ),
      ),
    );
    final saveButton = TextButton(
      onPressed: onSave,
      child: Text(l10n.editLinkPage_dialogAction_save),
    );
    final descriptionTextField = FocusOutTextField(
      minLines: 1,
      maxLines: 3,
      controller: descriptionController,
      decoration: InputDecoration(
        hintText: l10n.editLinkPage_dialog_description_hint,
      ),
    );
    return AlertDialog.adaptive(
      title: Text(l10n.editLinkPage_dialog_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isNeededToEditPath)
            ...[
              UriTextField(urlController, errorText: errorText),
              const SizedBox(height: 32),
            ],
          descriptionTextField,
        ],
      ),
      actions: [
        deleteButton,
        saveButton,
      ],
    );
  }
}
