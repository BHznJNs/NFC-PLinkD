import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
 
import 'package:nfc_plinkd/config.dart';
import 'package:nfc_plinkd/components/link_edit_view.dart';
import 'package:nfc_plinkd/components/drawer.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/pages/create/index.dart';
import 'package:nfc_plinkd/pages/gallery.dart';
import 'package:nfc_plinkd/pages/read.dart';
import 'package:nfc_plinkd/pages/settings/settings.dart';
import 'package:nfc_plinkd/providers/language_provider.dart';
import 'package:nfc_plinkd/providers/theme_provider.dart';
import 'package:nfc_plinkd/utils/open_link.dart';
import 'package:nfc_plinkd/utils/media/picker.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 
  late StreamSubscription<List<SharedMediaFile>> sharedSubscription;
  late StreamSubscription<Uri> linkSubscription;
  late StreamSubscription<FGBGType> fgbgSubscription;
  bool isInForeground = true;

  Future<void> initFgbg() async {
    fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      isInForeground = switch(event) {
        FGBGType.foreground => true,
        FGBGType.background => false,
      };
    });
  }

  Future<void> initMediaSharing() async {
    ResourcePickerResult resolveSharedFiles(List<SharedMediaFile> sharedFiles) {
      final resources = <(String, ResourceType)>[];
      for (final file in sharedFiles) {
        if (file.mimeType == null) continue;
        final resourceType = ResourceType.fromMimetype(file.mimeType!);
        if (resourceType == null) continue;
        resources.add((file.path, resourceType));
      }
      return resources;
    }

    ReceiveSharingIntent.instance.getInitialMedia().then((sharedFiles) {
      final resources = resolveSharedFiles(sharedFiles);
      if (navigatorKey.currentContext == null) return;
      if (resources.isEmpty) return;
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (context) {
          final l10n = S.of(context)!;
          return LinkEditView(
            title: l10n.createPage_title,
            resourcePickerResult: resources,
          );
        }),
      );
      ReceiveSharingIntent.instance.reset();
    });
    sharedSubscription = ReceiveSharingIntent.instance.getMediaStream().listen((sharedFiles) {
      final resources = resolveSharedFiles(sharedFiles);
      if (navigatorKey.currentContext == null) return;
      if (resources.isEmpty) return;
      Navigator.of(navigatorKey.currentContext!).push(
        MaterialPageRoute(builder: (context) {
          final l10n = S.of(context)!;
          return LinkEditView(
            title: l10n.createPage_title,
            resourcePickerResult: resources,
          );
        }),
      );
    }, onError: (err) {/* do nothing */});
  }

  Future<void> initDeepLinks() async {
    final appLinks = AppLinks();

    appLinks.getInitialLink().then((uri) {
      if (uri == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentContext == null) return;
        openLinkWithUri(navigatorKey.currentContext!, uri)
          .onError((error, _) => null);
      });
    });
    linkSubscription = appLinks.uriLinkStream.listen((uri) {
      if (isInForeground) return;
      if (navigatorKey.currentContext == null) return;
      openLinkWithUri(navigatorKey.currentContext!, uri)
        .onError((error, _) => null /* do nothing */);
    });
  }

  @override
  void initState() {
    super.initState();
    initFgbg();
    initDeepLinks();
    initMediaSharing();
  }

  @override
  void dispose() {
    linkSubscription.cancel();
    sharedSubscription.cancel();
    fgbgSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const sharedDrawer = ScaffoldDrawer();
    const colorTheme = Colors.blue;

    final defaultLightColorScheme = ColorScheme.fromSeed(
      seedColor: colorTheme,
      brightness: Brightness.light,
    );
    final defaultDarkColorScheme = ColorScheme.fromSeed(
      seedColor: colorTheme,
      brightness: Brightness.dark,
    );
    final routes = <String, Widget Function(BuildContext)>{
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

    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightColorScheme = lightDynamic ?? defaultLightColorScheme;
        final darkColorScheme = darkDynamic ?? defaultDarkColorScheme;
        return MaterialApp(
          onGenerateTitle: (BuildContext context) {
            return S.of(context)?.appTitle ?? 'NFC PLinkD';
          },
          locale: languageProvider.language.toLocale(),
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          navigatorKey: navigatorKey,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            cardTheme: CardTheme(
              color: Color.lerp(darkColorScheme.surface, Colors.white, 0.06),
            ),
          ),
          themeMode: themeProvider.theme.toThemeMode(),
          home: Builder(builder: routes['/create']!),
          routes: routes,
        );
      }
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final [isFirstLaunch, theme, language] = await Future.wait([
    Configuration.isFirstLaunch,
    Configuration.theme.read(),
    Configuration.language.read(),
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) =>
          LanguageProvider(language as ConfigLanguage?)),
        ChangeNotifierProvider(create: (_) =>
          ThemeProvider(theme as ConfigTheme?)),
      ],
      child: const MyApp(),
    ),
  );
}
