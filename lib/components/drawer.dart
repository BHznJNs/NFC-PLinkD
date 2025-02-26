import 'package:flutter/material.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';

class ScaffoldWithDrawer extends StatelessWidget {
  const ScaffoldWithDrawer({
    super.key,
    required this.title,
    required this.body,
    required this.drawer,
  });

  final String title;
  final Widget body;
  final ScaffoldDrawer drawer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      drawer: const ScaffoldDrawer(),
      body: body,
    );
  }
}

class ScaffoldDrawer extends StatelessWidget {
  const ScaffoldDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    final drawerItems = [
      _DrawerItemData(l10n.drawer_createPage , '/create'  , Icons.add_outlined                 , Icons.add                 ),
      _DrawerItemData(l10n.drawer_readPage   , '/read'    , Icons.tap_and_play_outlined        , Icons.tap_and_play        ),
      _DrawerItemData(l10n.drawer_galleryPage, '/gallery' , Icons.collections_bookmark_outlined, Icons.collections_bookmark),
      _DrawerItemData(l10n.drawer_settingPage, '/settings', Icons.settings_outlined            , Icons.settings            ),
    ];
    final currentRoute = (() {
      final routeName = ModalRoute.of(context)?.settings.name;
      if (routeName == null || routeName == '/') return '/create';
      return routeName;
    })();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const ScaffoldDrawerHeader(),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: drawerItems
                  .sublist(0, drawerItems.length - 1)
                  .map((item) => item.toDrawerItem(
                    currentRoute == item.route))
                  .toList(),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.only(top: 12, bottom: 24),
              child: drawerItems.last.toDrawerItem(
                currentRoute == drawerItems.last.route),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaffoldDrawerHeader extends StatelessWidget {
  const ScaffoldDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const leadingWidth = 56;
    final l10n = S.of(context)!;
    final safeLeftPadding = MediaQuery.of(context).padding.left;

    return Container(
      height: 56,
      padding: EdgeInsets.only(left: safeLeftPadding + leadingWidth / 2 - 24),
      child: Row(
        crossAxisAlignment : CrossAxisAlignment.center,
        children: [
          IconButton(
            iconSize: 24,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.menu_open),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 22,
            child: Text(
              l10n.appTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ),
        ]
      )
    );
  }
}

class _DrawerItem extends StatefulWidget {
  const _DrawerItem({
    this.icon,
    this.selectedIcon,
    required this.route,
    required this.label,
    this.isSelected = false,
  });

  final IconData? icon;
  final IconData? selectedIcon;
  final String route;
  final String label;
  final bool isSelected;

  @override
  State<StatefulWidget> createState() => _DrawerItemState();
}
class _DrawerItemState extends State<_DrawerItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = Icon(
      widget.isSelected
        ? widget.selectedIcon
        : widget.icon,
      color: widget.isSelected
        ? theme.colorScheme.primary
        : theme.iconTheme.color
    );
    final text = Text(
      widget.label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: widget.isSelected
          ? FontWeight.bold
          : FontWeight.w500
      ),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: widget.isSelected
          ? theme.colorScheme.primaryContainer
          : Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(128),
        child: ListTile(
          leading: icon,
          title: text,
          selected: widget.isSelected,
          onTap: () => Navigator.of(context).pushReplacementNamed(widget.route),
        ),
      ),
    );
  }
}

class _DrawerItemData {
  const _DrawerItemData(
    this.label, this.route,
    this.icon,  this.selectedIcon,
  );

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;

  NavigationDrawerDestination toNavigationDestination() =>
    NavigationDrawerDestination(
      label: Text(label),
      icon : Icon(icon),
      selectedIcon: Icon(selectedIcon)
    );
  _DrawerItem toDrawerItem(bool isSelected) =>
    _DrawerItem(
      label: label,
      route: route,
      icon : icon,
      selectedIcon: selectedIcon,
      isSelected: isSelected,
    );
}
