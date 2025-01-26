import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    final id = Uuid().v4();
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
          onPressed: () {},
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
      body: ListView.builder(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: images.length,
        itemBuilder: (context, index) =>
          _ImageItem.fromFile(images[index]),
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  _ImageItem.fromFile(XFile file): imagePath = file.path;

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      )
    );
  }
}
