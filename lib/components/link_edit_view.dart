import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nfc_plinkd/components/custom_button.dart';
import 'package:nfc_plinkd/pages/resource_view/resource_list_view.dart';
import 'package:nfc_plinkd/components/snackbar.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';
import 'package:nfc_plinkd/utils/media/picker.dart';

class LinkEditView extends StatefulWidget {
  const LinkEditView({
    super.key,
    required this.title,
    this.initialResources,
    this.resourcePickerResult,
    this.link,
  }) : assert(initialResources != null || resourcePickerResult != null,
        'Either `initialResources` or `resourcePickerResult` must be provided');

  final List<ResourceModel>? initialResources;
  final ResourcePickerResult? resourcePickerResult;
  final String title;
  final LinkModel? link;

  @override
  State<StatefulWidget> createState() => _LinkEditViewState();
}

class _LinkEditViewState extends State<LinkEditView> {
  final ImagePicker picker = ImagePicker();
  late String id = widget.link?.id ?? Uuid().v4();

  late bool isCreateView = widget.resourcePickerResult != null;
  late bool isReadView = widget.initialResources != null;
  late List<ResourceModel> resources;

  Future<void> writeIntoDatabase(DateTime now, {bool isUpdate = false}) async {
    final link = LinkModel(
      id: id,
      name: linkNameController.text,
      createTime: now.millisecondsSinceEpoch,
      modifyTime: now.millisecondsSinceEpoch,
    );
    final processedResources = await copyResourcesToAppDir(id, resources);
    isUpdate
      ? await DatabaseHelper.instance.updateLink(link, processedResources)
      : await DatabaseHelper.instance.insertLink(link, processedResources);        
  }

  Future<void> filePickerWrapper(ResourcePicker picker) async {
    final result = await picker(context);
    if (result.isEmpty) return;
    setState(() {
      for (final item in result) {
        resources.add(ResourceModel(
          linkId: id,
          type: item.$2,
          path: item.$1,
        ));
      }
    });
  }

  Future<void> saveLinkData() async {
    final l10n = S.of(context)!;
    if (resources.isEmpty) {
      showInfoSnackBar(context, l10n.editLinkPage_no_content_msg);
      return;
    }
    if (isReadView) {
      final now = DateTime.now();
      await writeIntoDatabase(now, isUpdate: true);
      if (mounted) await showSuccessMsg(context, text: l10n.editLinkPage_success_msg);
      if (mounted) {
        return Navigator.of(context).pop(LinkEditResult(
          linkNameController.text,
          now.millisecondsSinceEpoch,
        ));
      }
      return;
    }
    if (isCreateView) {
      // only write to NFC tag when creating
      if (!await checkNFCAvailability()) {
        if (!mounted) return;
        showCustomError(context, NFCError.NFCFunctionDisabled(context));
        return;
      }
      final linkUri = linkIdUriFactory(id);
      final dataToWrite = [NdefRecord.createUri(linkUri)];
      
      if (!mounted) return;

      Function? stopWriting;
      final isWriten = await showWaitingDialog(context,
        title: l10n.custom_dialog_nfc_approach_title,
        task: () async {
          final completer = Completer();
          stopWriting = await tryWriteNFCData(context, dataToWrite,
            onWrite: () async {
              final now = DateTime.now();
              await writeIntoDatabase(now);
              completer.complete(true);
            },
            onError: (e) {
              Navigator.of(context).pop();
              showCustomError(context, e);
              completer.complete(false);
            }
          );
          return completer.future;
        },
        onCanceled: () => false,
      );
      await stopWriting?.call();
      if (!isWriten) return;
      if (mounted) await showSuccessMsg(context, text: l10n.editLinkPage_success_msg);
      if (mounted) Navigator.of(context).pop(); // when successfully saved, close this page
    }
  }

  bool isEditingLinkName = false;
  final linkNameFocusNode = FocusNode();
  late String? initialLinkName = widget.link?.name;
  late TextEditingController linkNameController =
    TextEditingController(text: widget.link?.name);
  Widget linkNameEditorBuilder() {
    final l10n = S.of(context)!;
    return TextField(
      maxLines: 1,
      autofocus: true,
      controller: linkNameController,
      focusNode: linkNameFocusNode,
      decoration: InputDecoration(
        hintText: l10n.editLinkPage_linkName_hint,
        suffixIcon: IconButton(
          onPressed: () => linkNameController.clear(),
          icon: Icon(Icons.delete),
        ),
      ),
      onTapOutside: (_) => linkNameFocusNode.unfocus(),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialResources != null) {
      resources = widget.initialResources!;
    } else
    if (widget.resourcePickerResult != null) {
      resources = widget.resourcePickerResult!
        .map((resource) => ResourceModel(
          linkId: id,
          type: resource.$2,
          path: resource.$1,
        )).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColorMap = isDarkMode ? {
      'video': Colors.blueGrey.shade600,
      'audio': Colors.purple.shade700,
      'weblink': Colors.teal.shade700,
      'upload': Colors.amber.shade700,
    } : {
      'video': Colors.indigo.shade400,
      'audio': Colors.deepPurple.shade400,
      'weblink': Colors.teal.shade400,
      'upload': Colors.amber.shade400,
    };
    final speedDialChildren = [
      SpeedDialChild(
        label: l10n.editLinkPage_actionLabel_video,
        child: Icon(Icons.videocam),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['video'],
        onTap: () => filePickerWrapper(recordVideo),
      ),
      SpeedDialChild(
        label: l10n.editLinkPage_actionLabel_audio,
        child: Icon(Icons.mic),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['audio'],
        onTap: () => filePickerWrapper(recordAudio),
      ),
      SpeedDialChild(
        label: l10n.editLinkPage_actionLabel_weblink,
        child: Icon(Icons.link),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['weblink'],
        onTap: () => filePickerWrapper(inputWebLink),
      ),
      SpeedDialChild(
        label: l10n.editLinkPage_actionLabel_upload,
        child: Icon(Icons.upload),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['upload'],
        onTap: () => filePickerWrapper(pickMediaFile),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: isEditingLinkName
          ? linkNameEditorBuilder()
          : Text(widget.title),
        actions: [
          isEditingLinkName 
            ? IconButton(
                onPressed: () => setState(() => isEditingLinkName = false),
                icon: const Icon(Icons.close),
              )
            : IconButton(
                onPressed: () => setState(() => isEditingLinkName = true),
                icon: const Icon(Icons.edit),
              ),
          IconButton(
            onPressed: saveLinkData,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      floatingActionButton: EnhancedSpeedDial(
        speedDialChildren,
        activeLabel: l10n.editLinkPage_actionLabel_image,
        activeIcon: Icons.add_a_photo,
        onDialRootPressed: (isOpen) {
          if (!isOpen) {
            filePickerWrapper(takePhoto);
          }
        },
      ),
      body: ResourceListView(resources),
    );
  }
}

class LinkEditResult {
  const LinkEditResult(this.name, this.modifyTime);
  final String name;
  final int modifyTime;
}
