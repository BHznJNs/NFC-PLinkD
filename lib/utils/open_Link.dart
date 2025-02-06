import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';

Future<void> openLinkWithUri(Uri uri, {
  BuildContext? context,
  NavigatorState? navigator,
  Function? onBack,
}) async {
  if (uri.host != linkHost || uri.pathSegments.isEmpty) {
    throw NFCError.NFCTagDataInvalid;
  }
  final targetId = uri.pathSegments[0];
  await openLinkWithId(targetId,
    context: context,
    navigator: navigator,
    onBack: onBack,
  );
}

Future<void> openLinkWithId(String id,  {
  BuildContext? context,
  NavigatorState? navigator,
  Function? onBack,
}) async {
  final (link, resources) = await DatabaseHelper.instance.fetchLink(id);
  final dataBasePath = await getDataBasePath(link.id);
  final resolvedResources = resources.map((resource) =>
    resource.copyWith(
      path: '$dataBasePath/${resource.path}')
  ).toList();

  NavigatorState? targetNavigator;
  if (context != null && context.mounted) {
    targetNavigator = Navigator.of(context);
  } else if (navigator != null) {
    targetNavigator = navigator;
  }
  if (targetNavigator == null) return;
  await _openWithNavigator(targetNavigator, id, resolvedResources, onBack);
}

Future<void> _openWithNavigator(
  NavigatorState targetNavigator,
  String id,
  List<ResourceModel> resources,
  Function? onBack,
) async {
  await targetNavigator.push(
    MaterialPageRoute(builder: (context) =>
      LinkEditView(
        linkId: id,
        title: 'Edit a Link',
        initialResources: resources,
      )
  ));
  await onBack?.call();
}