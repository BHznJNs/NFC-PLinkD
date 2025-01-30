import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:app_links/app_links.dart';

import 'package:nfc_plinkd/pages/create/page.dart';
import 'package:nfc_plinkd/components/drawer.dart';
import 'package:nfc_plinkd/pages/gallery.dart';
import 'package:nfc_plinkd/pages/read.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late AppLinks appLinks;
  StreamSubscription<Uri>? linkSubscription;

  Future<void> initDeepLinks() async {
    appLinks = AppLinks();
    linkSubscription = appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      // openAppLink(uri);
    });
  }

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sharedDrawer = ScaffoldDrawer();
    final colorTheme = Colors.blue;
    final defaultLightColorScheme = ColorScheme.fromSeed(
      seedColor: colorTheme,
      brightness: Brightness.light,
    );
    final defaultDarkColorScheme = ColorScheme.fromSeed(
      seedColor: colorTheme,
      brightness: Brightness.dark,
    );
    final createPage  = ScaffoldWithDrawer(title: 'Create a Link', body: CreatePage(), drawer: sharedDrawer);
    final readPage    = ScaffoldWithDrawer(title: 'Read a Link', body: ReadPage(), drawer: sharedDrawer);
    final galleryPage = ScaffoldWithDrawer(title: 'My Links', body: GalleryPage(), drawer: sharedDrawer);
    final routes = {
      '/create' : (context) => createPage,
      '/read'   : (context) => readPage,
      '/gallery': (context) => galleryPage,
    };

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) => MaterialApp(
        title: 'NFC PLinkD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ?? defaultLightColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ?? defaultDarkColorScheme,
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/create',
        routes: routes,
      )
    );
  }
}

void main() => runApp(const MyApp());
