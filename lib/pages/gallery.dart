import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/utils/formatter.dart';
import 'package:nfc_plinkd/utils/open_Link.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<LinkModel>? links;

  Future<void> loadData() async {
    links = await DatabaseHelper.instance.fetchLinks();
  }

  Future<void> openLink(int index) async {
    if (links == null) return;
    final linkId = links![index].id;
    openLinkWithId(linkId, navigator: Navigator.of(context));
  }

  Future<void> deleteLink(int index) async {
    if (links == null) return;
    final result = await showDeleteDialog(context);
    if (!result) return;

    await DatabaseHelper.instance.deleteLink(links![index]);
    setState(() => links!.removeAt(index));
  }

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance
      .fetchLinks(orderBy: OrderBy.createTimeRev)
      .then((fetched) =>
        setState(() => links = fetched));
  }

  @override
  Widget build(BuildContext context) {
    if (links == null) {
      return Center(child: Container(
        width: 64,
        height: 64,
        margin: EdgeInsets.only(bottom: 64),
        child: CircularProgressIndicator.adaptive(),
      ));
    }
    if (links!.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 12),
        alignment: Alignment.topCenter,
        child: Text(
          // 还没有链接，快去创建吧！
          'No links available. Please create one!',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: links!.length,
      itemBuilder: (context, index) => _LinkItem(
        links![index], index,
        onOpen: openLink,
        onDelete: deleteLink,
      ),
    );
  }
}

class _LinkItem extends StatelessWidget {
  const _LinkItem(this.metadata, this.index, {
    this.onOpen,
    this.onDelete,
  });

  final LinkModel metadata;
  final int index;
  final Function(int)? onOpen;
  final Function(int)? onDelete;

  static const popupMenuItems = [
    PopupMenuItem<String>(
      value: 'open',
      child: Text('Open'),
    ),
    PopupMenuItem<String>(
      value: 'delete',
      child: Text('Delete'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final createTimeDateString = formatTimestampToLocalizedDate(context, metadata.createTime);
    final createTimeHourMinuteString = formatTimestampToHourMinute(metadata.createTime);
    return Card(
      elevation: 4.0,
      child: InkWell(
        onTap: () => onOpen?.call(index),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          title: Text(createTimeDateString),
          subtitle: Text(createTimeHourMinuteString),
          leading: const Icon(Icons.nfc, size: 40),
          trailing: PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'open': onOpen?.call(index);
                case 'delete': onDelete?.call(index);
                default: throw UnimplementedError();
              }
            },
            itemBuilder: (BuildContext context) => popupMenuItems,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
