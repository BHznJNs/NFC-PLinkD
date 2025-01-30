import 'package:flutter/material.dart';

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

  static const drawerItems = [
    _DrawerItemData('New Link' , '/create' , Icons.add_outlined                 , Icons.add                 ),
    _DrawerItemData('Read Link', '/read'   , Icons.tap_and_play_outlined        , Icons.tap_and_play        ),
    _DrawerItemData('My Links' , '/gallery', Icons.collections_bookmark_outlined, Icons.collections_bookmark),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/create';
    final selectedIndex = drawerItems.indexWhere((item) => item.route == currentRoute);
    final routerDestinations = drawerItems.map((destination) => 
      NavigationDrawerDestination(
        label: Text(destination.label),
        icon : Icon(destination.icon),
        selectedIcon: Icon(destination.selectedIcon)
      )
    ).toList();

    return NavigationDrawer(
      onDestinationSelected: (int selectedScreen) {
        final targetRoute = drawerItems[selectedScreen].route;
        if (currentRoute == targetRoute) return;
        Navigator.pushReplacementNamed(context, targetRoute);
      },
      selectedIndex: selectedIndex,
      children: [
        const ScaffoldDrawerHeader(),
        ...routerDestinations,
      ],
    );
  }
}

class ScaffoldDrawerHeader extends StatelessWidget {
  const ScaffoldDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    const leadingWidth = 56;
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
          const SizedBox(
            height: 22,
            child: Text(
              'NFC PLinkD',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            )
          ),
        ]
      )
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
}
