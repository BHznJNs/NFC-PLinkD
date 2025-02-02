import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePage extends StatelessWidget {
  const ImagePage(this.path, {super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        imageProvider: FileImage(File(path)),
      ),
    );
  }
}
