import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/utils/formatter.dart';
import 'package:nfc_plinkd/utils/open_link.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<StatefulWidget> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late List<LinkModel> links;
  int? linkCount;
  int currentPage = 0;
  bool isLoading = true;
  bool isLoadingMore = false;

  get hasMoreData {
    if (linkCount == null) return false;
    return linkCount! > currentPage * DatabaseHelper.defaultPageSize;
  }

  Future<void> loadMoreData() async {
    if (!hasMoreData) return;
    isLoadingMore = true; // since the `isLoadingMore` is not used in UI, there is not need to wrap it in `setState`
    final newLinks = await DatabaseHelper.instance.fetchLinks(
      page: currentPage
    );
    currentPage += 1;
    setState(() => links.addAll(newLinks));
    isLoadingMore = false;
  }

  Future<void> openLink(int index) async {
    final linkId = links[index].id;
    openLinkWithId(context, linkId);
  }

  Future<void> deleteLink(int index) async {
    final result = await showDeleteDialog(context);
    if (!result) return;

    await DatabaseHelper.instance.deleteLink(links[index]);
    setState(() => links.removeAt(index));
  }

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance
      .getLinkCount()
      .then((count) => linkCount = count);
    DatabaseHelper.instance
      .fetchLinks()
      .then((fetched) {
        currentPage += 1;
        setState(() {
          links = fetched;
          isLoading = false;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    if (isLoading) {
      return Center(child: Container(
        width: 64,
        height: 64,
        margin: EdgeInsets.only(bottom: 64),
        child: CircularProgressIndicator.adaptive(),
      ));
    }
    if (links.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 12),
        alignment: Alignment.topCenter,
        child: Text(
          // 还没有链接，快去创建吧！
          l10n.galleryPage_emptyText,
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        final isScrolledToBottom = notification.metrics.pixels >= notification.metrics.maxScrollExtent - 16;
        final isScrollEndNotification = notification is ScrollEndNotification;
        if (!isLoading && !isLoadingMore && isScrolledToBottom && isScrollEndNotification) {
          loadMoreData();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: links.length,
        itemBuilder: (context, index) => _LinkItem(
          links[index], index,
          onOpen: openLink,
          onDelete: deleteLink,
        ),
      ),
    );
    // return ListView.builder(
    //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    //   itemCount: links!.length,
    //   itemBuilder: (context, index) => _LinkItem(
    //     links![index], index,
    //     onOpen: openLink,
    //     onDelete: deleteLink,
    //   ),
    // );
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

  static List<PopupMenuItem> popupMenuItems(BuildContext context) {
    final l10n = S.of(context)!;
    return [
      PopupMenuItem<String>(
        value: 'open',
        child: Text(l10n.galleryPage_popup_open),
      ),
      PopupMenuItem<String>(
        value: 'delete',
        child: Text(l10n.galleryPage_popup_delete),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final createTimeDateString = formatTimestampToLocalizedDate(context, metadata.createTime);
    final createTimeHourMinuteString = formatTimestampToHourMinute(metadata.createTime);
    return Card(
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
            itemBuilder: (BuildContext context) => popupMenuItems(context),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }
}
