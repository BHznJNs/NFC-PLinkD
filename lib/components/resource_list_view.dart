import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_plinkd/db.dart';

class ResourceListView extends StatelessWidget {
  const ResourceListView(this.resourceList, {super.key});

  final List<ResourceModel> resourceList;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 80),
      onReorder: (oldIndex, newIndex) {
        // 
      },
      itemCount: resourceList.length,
      itemBuilder: (context, index) {
        final resource = resourceList[index];
        return _GenericResourceItem(
          key: ValueKey(index),
          path: resource.path,
          type: resource.type,
        );
      },
    );
  }
}

class _GenericResourceItem extends StatelessWidget {
  const _GenericResourceItem({
    super.key,
    required this.path,
    required this.type,
  });

  final String path;
  final ResourceType type;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      ResourceType.image => _ImageItem(path),
      ResourceType.video => _VideoItem(path),
      ResourceType.audio => _AudioItem(path),
      ResourceType.webLink => _WebLinkItem(path),
    };
  }
}

class _ImageItem extends StatelessWidget {
  const _ImageItem(this.path);

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
  const _VideoItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _AudioItem extends StatelessWidget {
  const _AudioItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _WebLinkItem extends StatelessWidget {
  const _WebLinkItem(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
