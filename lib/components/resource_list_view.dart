import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_plinkd/db.dart';

class ResourceListView extends StatelessWidget {
  const ResourceListView({
    super.key,
    required this.resourcePathList,
    required this.resourceType,
  });

  final List<String> resourcePathList;
  final LinkType resourceType;

  @override
  Widget build(BuildContext context) {
    final targetItemWidget = switch (resourceType) {
      LinkType.image => (String path) => _ImageItem(path: path),
      LinkType.video => () => _VideoItem(),
      LinkType.audio => () => _AudioItem(),
      LinkType.webLink => () => _WebLinkItem(),
    };
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
      itemCount: resourcePathList.length,
      itemBuilder: (context, index) =>
        targetItemWidget(resourcePathList[index]),
    );
  }
}

class _ImageItem extends StatelessWidget {
  const _ImageItem({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
        ),
      )
    );
  }
}

class _VideoItem extends StatelessWidget {
  const _VideoItem();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _AudioItem extends StatelessWidget {
  const _AudioItem();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _WebLinkItem extends StatelessWidget {
  const _WebLinkItem();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
