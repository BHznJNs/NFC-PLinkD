import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';

Future<void> openLinkWithUri(BuildContext context, Uri uri) async {
  if (uri.host != linkHost || uri.pathSegments.isEmpty) {
    throw NFCError.NFCTagDataInvalid(context);
  }
  final targetId = uri.pathSegments[0];

  await openLinkWithId(context, targetId);
}

Future<void> openLinkWithId(BuildContext context, String id) async {
  final (link, resources) = await DatabaseHelper.instance.fetchLink(id);
  final basePath = await getBasePath(link.id);
  final resolvedResources = resources.map((resource) =>
    resource.copyWith(
      path: '$basePath/${resource.path}')
  ).toList();

  if (!context.mounted) return;
  await _openWithNavigator(context, link, resolvedResources);
}

Future<void> _openWithNavigator(
  BuildContext context,
  LinkModel link,
  List<ResourceModel> resources,
) async {
  final l10n = S.of(context)!;
  await Navigator.of(context).push(
    MaterialPageRoute(builder: (context) =>
      LinkEditView(
        link: link,
        title: l10n.editLinkPage_title,
        initialResources: resources,
      )
  ));
}