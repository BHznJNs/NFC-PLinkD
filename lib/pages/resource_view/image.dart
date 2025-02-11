import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  const ImagePage(this.path, {super.key});

  final String path;

  void share() {
    Share.shareXFiles([XFile(path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: share,
          icon: Icon(Icons.share),
        )
      ]),
      body: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        imageProvider: FileImage(File(path)),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
        ),
      ),
    );
  }
}
