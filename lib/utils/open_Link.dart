import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/utils/file.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';

Future<void> openLinkWithUri(BuildContext context, Uri uri, {
  NavigatorState? navigator,
  Function? onBack,
}) async {
  if (uri.host != linkHost || uri.pathSegments.isEmpty) {
    throw NFCError.NFCTagDataInvalid(context);
  }
  final targetId = uri.pathSegments[0];

  await openLinkWithId(context, targetId,
    navigator: navigator,
    onBack: onBack,
  );
}

Future<void> openLinkWithId(BuildContext context, String id, {
  NavigatorState? navigator,
  Function? onBack,
}) async {
  final targetNavigator = navigator ?? Navigator.of(context);
  final (link, resources) = await DatabaseHelper.instance.fetchLink(id);
  final dataBasePath = await getDataBasePath(link.id);
  final resolvedResources = resources.map((resource) =>
    resource.copyWith(
      path: '$dataBasePath/${resource.path}')
  ).toList();

  if (!context.mounted) return;
  await _openWithNavigator(context, targetNavigator, id, resolvedResources, onBack);
}

Future<void> _openWithNavigator(
  BuildContext context,
  NavigatorState targetNavigator,
  String id,
  List<ResourceModel> resources,
  Function? onBack,
) async {
  final l10n = S.of(context)!;
  await targetNavigator.push(
    MaterialPageRoute(builder: (context) =>
      LinkEditView(
        linkId: id,
        title: l10n.editLinkPage_title,
        initialResources: resources,
      )
  ));
  await onBack?.call();
}