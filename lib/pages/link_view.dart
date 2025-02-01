import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/resource_list_view.dart';
import 'package:nfc_plinkd/db.dart';

class LinkView extends StatelessWidget {
  const LinkView(this.resources, {super.key});

  final List<ResourceModel> resources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Content'),
      ),
      body: ResourceListView(resources),
    );
  }
}
