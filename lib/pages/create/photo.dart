import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nfc_plinkd/components/custom_button.dart';
import 'package:nfc_plinkd/components/resource_list_view.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/utils/media.dart';
import 'package:nfc_plinkd/components/snackbar.dart';
import 'package:nfc_plinkd/components/dialog.dart';
import 'package:nfc_plinkd/components/nfc_modal.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final String id = Uuid().v4();
  final ImagePicker picker = ImagePicker();
  final List<ResourceModel> resources = [];

  Future<void> filePickerWrapper(ResourcePicker picker) async {
    final result = await picker(context);
    if (result.isEmpty) return;
    setState(() {
      for (var item in result) {
        resources.add(ResourceModel(
          linkId: id,
          type: item.$2,
          path: item.$1.path,
        ));
      }
    });
  }

  Future<void> saveLink() async {
    if (resources.isEmpty) {
      showInfoSnackBar(context, 'There is no photo, please add some');
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;

    showNFCWritingModal(
      context, id,
      onSuccess: () async {
        showNFCWritingSuccessMsg(context, () => Navigator.of(context).pop());

        final link = LinkModel(id: id, createTime: now);
        final processedResources = await moveResourcesToAppDir(id, resources);
        await DatabaseHelper.instance.insertLink(link, processedResources);        
      },
      onError: (err) =>
        showCustomError(context, err),
    );
  }

  @override
  void initState() {
    super.initState();
    takePhoto(context).then((result) {
      if (result.isEmpty) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        return;
      }
      final photo = result[0];
      setState(() => resources.add(ResourceModel(
        linkId: id,
        type: photo.$2,
        path: photo.$1.path,
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
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
        label: 'Record a video',
        child: Icon(Icons.videocam),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['video'],
        onTap: () => filePickerWrapper(recordVideo),
      ),
      SpeedDialChild(
        label: 'Record a audio',
        child: Icon(Icons.mic),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['audio'],
        onTap: () => filePickerWrapper(recordAudio),
      ),
      SpeedDialChild(
        label: 'Attach a web link',
        child: Icon(Icons.link),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['weblink'],
      ),
      SpeedDialChild(
        label: 'Upload some resource',
        child: Icon(Icons.upload),
        foregroundColor: Colors.white,
        backgroundColor: bgColorMap['upload'],
        onTap: () => filePickerWrapper(pickMediaFile),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Create a Link'),
        actions: [TextButton(
          onPressed: saveLink,
          child: Text('Finish'),
        )],
      ),
      floatingActionButton: EnhancedSpeedDial(
        speedDialChildren,
        onDialRootPressed: (isOpen) {
          print('isOpen: $isOpen');
        },
      ),
      body: ResourceListView(resources),
    );
  }
}
