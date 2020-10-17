import 'dart:ffi';

import 'package:flutter/cupertino.dart'
    show
        CupertinoActionSheet,
        CupertinoActionSheetAction,
        CupertinoActivityIndicator,
        CupertinoDynamicColor,
        CupertinoIcons,
        CupertinoThemeData,
        DefaultCupertinoLocalizations;
import 'package:flutter/material.dart'
    show
        Colors,
        DefaultMaterialLocalizations,
        Icons,
        Theme,
        ThemeData,
        ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Services/test_preference.dart';
import 'package:mangasoup_prototype_3/landing.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SourceNotifier()),
      ],
      child: App(),
    ),
  );
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  Brightness brightness = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final materialTheme = ThemeData(primaryColor: Colors.black);
    final materialDarkTheme = ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent);

    final cupertinoTheme = CupertinoThemeData(
      brightness: brightness, // if null will use the system theme
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: Colors.black,
        darkColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.black,
    );

    // Example of optionally setting the platform upfront.
    //final initialPlatform = TargetPlatform.iOS;

    // If you mix material and cupertino widgets together then you cam
    // set this setting. Will mean ios darmk mode to not to work properly
    //final settings = PlatformSettingsData(iosUsesMaterialWidgets: true);

    // This theme is required since icons light/dark mode will look for it
    return Theme(
      data: brightness == Brightness.light ? materialTheme : materialDarkTheme,
      child: PlatformProvider(
        builder: (_) => PlatformApp(
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'Flutter Platform Widgets',
          material: (_, __) {
            return MaterialAppData(
              theme: materialTheme,
              darkTheme: materialDarkTheme,
              themeMode: ThemeMode.dark,
              builder: (context, widget) => ResponsiveWrapper.builder(
                BouncingScrollWrapper.builder(context, widget),
                maxWidth: 1200,
                minWidth: 450,
                defaultScale: true,
                breakpoints: [
                  ResponsiveBreakpoint.resize(450, name: MOBILE),
                  ResponsiveBreakpoint.autoScale(800, name: TABLET),
                  ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                  ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                  ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                ],
                background: Container(color: Colors.black),
              ),
            );
          },
          cupertino: (_, __) => CupertinoAppData(
            theme: cupertinoTheme,
            builder: (context, widget) => ResponsiveWrapper.builder(
              BouncingScrollWrapper.builder(context, widget),
              maxWidth: 1200,
              minWidth: 450,
              defaultScale: true,

              breakpoints: [
                ResponsiveBreakpoint.resize(450, name: MOBILE),
                ResponsiveBreakpoint.autoScale(800, name: TABLET),
                ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                ResponsiveBreakpoint.autoScale(2460, name: "4K"),
              ],
              background: Container(color: Colors.black),
            ),
          ),

          initialRoute: "handler",
          // (_firstRun) ? "sources" : "landing",
          debugShowCheckedModeBanner: false,
          routes: {
            "/": (_)=> Landing(),
            "handler": (_) => Handler(),
            "/sources": (_) => SourcesPage(),
            "landing": (_) => Landing(),
          },
        ),
      ),
    );
  }
}

class Handler extends StatefulWidget {
  @override
  _HandlerState createState() => _HandlerState();
}

class _HandlerState extends State<Handler> {
  Future<bool> initSource() async {
    TestPreference _prefs = TestPreference();
    await _prefs.init();
    Source source = await _prefs.loadSource();
    if (source == null) {
      debugPrint("Not Initialized");
      return true;
    } else {
      await Provider.of<SourceNotifier>(context, listen: false)
          .loadSource(source);
      return false;
    }
  }

  Future<bool> firstLaunch;
  @override
  void initState() {
    super.initState();
    firstLaunch = initSource();
  }

  @override
  Widget build(BuildContext c) {
    return FutureBuilder(
        future: firstLaunch,
        builder: (BuildContext cxt, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          if (snapshot.hasData) {
            bool _x = snapshot.data;
            if (_x)
              return SourcesPage();
            else
              return Landing();
          } else
            return Text(
              "error",
              style: TextStyle(color: Colors.white),
            );
        });
  }
}
