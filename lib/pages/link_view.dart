import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/resource_list_view.dart';
import 'package:nfc_plinkd/db.dart';

class LinkView extends StatelessWidget {
  const LinkView({
    super.key,
    required this.resourcePathList,
    required this.resourceType,
  });

  final List<String> resourcePathList;
  final LinkType resourceType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Content'),
      ),
      body: ResourceListView(
        resourcePathList: resourcePathList,
        resourceType: resourceType,
      ),
    );
  }
}
