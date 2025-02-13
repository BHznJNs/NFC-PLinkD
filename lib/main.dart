import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:app_links/app_links.dart';
 
import 'package:nfc_plinkd/pages/create.dart';
import 'package:nfc_plinkd/config.dart';
import 'package:nfc_plinkd/components/drawer.dart';
import 'package:nfc_plinkd/pages/gallery.dart';
import 'package:nfc_plinkd/pages/read.dart';
import 'package:nfc_plinkd/pages/settings.dart';
import 'package:nfc_plinkd/utils/open_link.dart';

class MyApp extends StatefulWidget {
  const MyApp(this.theme, {super.key});

  final ConfigTheme? theme;

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 
  late AppLinks appLinks;
  bool isInForeground = true;
  StreamSubscription<Uri>? linkSubscription;

  Future<void> initDeepLinks() async {
    appLinks = AppLinks();
    appLinks.getInitialLink().then((uri) {
      if (uri == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext == null) return;
        openLinkWithUri(navigatorKey.currentContext!, uri)
          .onError((error, _) => {/* do nothing */});
      });
    });
    linkSubscription = appLinks.uriLinkStream.listen((uri) {
      if (isInForeground || !mounted) return;
      if (navigatorKey.currentContext == null) return;
      openLinkWithUri(navigatorKey.currentContext!, uri)
        .onError((error, _) {/* do nothing */});
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinks();
  }

  @override
  void dispose() {
    linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isInForeground =
      state == AppLifecycleState.resumed ||
      state == AppLifecycleState.inactive;
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
    final routes = {
      '/create': (context) => ScaffoldWithDrawer(
          title: S.of(context)?.drawer_createPage ?? 'Create a Link',
          body: CreatePage(),
          drawer: sharedDrawer,
      ),
      '/read': (context) => ScaffoldWithDrawer(
          title: S.of(context)?.drawer_readPage ?? 'Read a Link',
          body: ReadPage(),
          drawer: sharedDrawer,
      ),
      '/gallery': (context) => ScaffoldWithDrawer(
          title: S.of(context)?.drawer_galleryPage ?? 'Link Gallery',
          body: GalleryPage(),
          drawer: sharedDrawer,
      ),
      '/settings': (context) => ScaffoldWithDrawer(
          title: S.of(context)?.drawer_settingPage ?? 'Settings',
          body: SettingsPage(),
          drawer: sharedDrawer,
      ),
    };

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) => MaterialApp(
        onGenerateTitle: (BuildContext context) {
          return S.of(context)?.appTitle ?? 'NFC PLinkD';
        },
        navigatorKey: navigatorKey,
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightDynamic ?? defaultLightColorScheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkDynamic ?? defaultDarkColorScheme,
        ),
        themeMode: widget.theme?.toThemeMode() ?? ThemeMode.system,
        initialRoute: '/create',
        routes: routes,
      )
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final [isFirstLaunch, theme] = await Future.wait([
    Configuration.isFirstLaunch,
    Configuration.theme.read(),
  ]);
  if (isFirstLaunch as bool) {
    await Configuration.init();
    runApp(const MyApp(null));
  } else {
    runApp(MyApp(theme as ConfigTheme));
  }
}
