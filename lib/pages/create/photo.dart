import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/resource_list_view.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import 'package:nfc_plinkd/components/snackbar.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/components/dialog.dart';
import 'package:nfc_plinkd/components/nfc_modal.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key});

  @override
  State<StatefulWidget> createState() => _PhotoPageState();
}
class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = [];

  Future<void> takePhoto() async {
    final XFile? photo =
      await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;
    setState(() {
      images.add(photo);
    });
  }

  Future<void> importPhoto() async {
    final XFile? photo =
      await picker.pickImage(source: ImageSource.gallery);
    if (photo == null) return;
    setState(() {
      images.add(photo);
    });
  }

  Future<void> saveLink() async {
    if (images.isEmpty) {
      showInfoSnackBar(context, 'There is no photo, please add some');
      return;
    }
    final id = Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    showNFCWritingModal(
      context, id,
      onSuccess: () async {
        showNFCWritingSuccessMsg(context, () => Navigator.of(context).pop());

        final link = LinkModel(id: id, type: LinkType.image, createTime: now);
        final pathList = await moveResourcesToAppDir(images, LinkType.image);
        final resources = pathList.map((path) =>
          ResourceModel(linkId: id, path: path)
        ).toList();
        await DatabaseHelper.instance.insertLink(link, resources);        
      },
      onError: (err) =>
        showCustomError(context, err),
    );
  }

  @override
  void initState() {
    super.initState();
    takePhoto();
  }

  @override
  Widget build(BuildContext context) {
    final floatingActionButtons = Stack(children: [
      Positioned(
        bottom: 0,
        right: 0,
        child: FloatingActionButton.extended(
          heroTag: 'photo_finish',
          onPressed: saveLink,
          label: Text('Finish'),
          icon: Icon(Icons.check),
        ),
      ),
      Positioned(
        bottom: 72, right: 0,
        child: FloatingActionButton.small(
          heroTag: 'photo_take-photo',
          onPressed: takePhoto,
          child: Icon(Icons.add_a_photo),
        ),
      ),
      Positioned(
        bottom: 128, right: 0,
        child: FloatingActionButton.small(
          heroTag: 'photo_import-photo',
          onPressed: importPhoto,
          child: Icon(Icons.upload),
        ),
      ),
    ]);

    return Scaffold(
      appBar: AppBar(title: Text('拍照')),
      floatingActionButton: floatingActionButtons,
      body: ResourceListView(
        resourcePathList: images.map((xfile) => xfile.path).toList(),
        resourceType: LinkType.image,
      ),
    );
  }
}
