import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:nfc_plinkd/create/page.dart';
import 'package:nfc_plinkd/drawer.dart';
import 'package:nfc_plinkd/gallery.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedDrawer = ScaffoldDrawer();
    final colorTheme = Colors.blue;
    final routes = {
      '/create': (context)  =>
        ScaffoldWithDrawer(title: 'Create a Link', body: CreatePage(), drawer: sharedDrawer),
      '/gallery': (context) =>
        ScaffoldWithDrawer(title: 'My Links', body: Gallery(), drawer: sharedDrawer),
    };

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) => MaterialApp(
        title: 'NFC PLinkD',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ?? ColorScheme.fromSeed(
            seedColor: colorTheme,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ?? ColorScheme.fromSeed(
            seedColor: colorTheme,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/create',
        routes: routes,
      )
    );
  }
}

void main() => runApp(const MyApp());
