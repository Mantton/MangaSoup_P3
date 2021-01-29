import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/BrowseProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Providers/ReaderProvider.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Services/test_preference.dart';
import 'package:mangasoup_prototype_3/Services/update_manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/landing.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:workmanager/workmanager.dart';

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() {
//  UpdateManager test = UpdateManager();
  Workmanager.executeTask((task, inputData) async {
    /// initialize notifications settings
    FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    var initSettings = InitializationSettings(android: android, iOS: iOS);
    flp.initialize(initSettings, onSelectNotification: selectNotification);

    /// Update Manager
    UpdateManager _updateManger = UpdateManager();
    int updateCount = 0;

    /// Task Manager
    switch (task) {
      case simplePeriodicTask:
        print("Android BG Task Triggered");
        updateCount = await _updateManger.checkForUpdate();
        stderr.writeln("Check Complete");

        if (updateCount > 0) {
          if (updateCount == 1)
            showNotification("$updateCount new update in your library", flp);
          else
            showNotification("$updateCount new updates in your library", flp);
        }
        break;
      case Workmanager.iOSBackgroundTask:
        stderr.writeln("The iOS background fetch was triggered");
        var connectivityResult = await (Connectivity()
            .checkConnectivity()); //Check if user is connected
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
          // Only Check for updates with the user connected to a valid network
          updateCount = await _updateManger.checkForUpdate();
        }
        if (updateCount > 0) {
          if (updateCount == 1)
            showNotification("$updateCount new update in your library", flp);
          else
            showNotification("$updateCount new updates in your library", flp);
        }
        stderr.writeln("Done");
        break;
    }
    return Future.value(true);
  });
}

Future selectNotification(String payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  debugPrint("Notification was clicked!");
}

void showNotification(v, flp) async {
  var android = AndroidNotificationDetails(
      'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
      priority: Priority.high, importance: Importance.max);
  var iOS = IOSNotificationDetails();
  var platform = NotificationDetails(android: android, iOS: iOS);
  await flp.show(0, 'Collections', '$v', platform, payload: 'VIS : $v');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: false);

  // await FlutterDownloader.initialize(debug: false); this is causing issues on IOS

  if (Platform.isAndroid) {
    await Workmanager.registerPeriodicTask(
      "1",
      simplePeriodicTask,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      frequency: Duration(hours: 2),
      initialDelay: Duration(hours: 1), // start task 1 hour after app launch
      constraints: Constraints(
        networkType: NetworkType.connected,
        // requiresCharging: true, // this is tentative
      ),
    );
  }
  runApp(
    MultiProvider(
      providers: [
        // Source
        ChangeNotifierProvider(create: (_) => SourceNotifier()),
        // Highlight
        ChangeNotifierProvider(create: (_) => ComicHighlightProvider()),
        // Read History
        // View History
        ChangeNotifierProvider(create: (_) => BrowseProvider()),
        // ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
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
        color: Colors.blue,
        darkColor: Colors.blue,
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
          navigatorObservers: [BotToastNavigatorObserver()],
          material: (_, __) {
            return MaterialAppData(
                theme: materialTheme,
                darkTheme: materialDarkTheme,
                themeMode: ThemeMode.dark,
                builder: (context, widget) {
                  widget = BotToastInit()(context, widget);
                  return ResponsiveWrapper.builder(
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
                  );
                });
          },
          cupertino: (_, __) => CupertinoAppData(
              theme: cupertinoTheme,
              builder: (context, widget) {
                widget = BotToastInit()(context, widget);
                return ResponsiveWrapper.builder(
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
                );
              }),

          initialRoute: "handler",
          // (_firstRun) ? "sources" : "landing",
          debugShowCheckedModeBanner: false,
          routes: {
            "/": (_) => Landing(),
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
    debugPrint("Start Up");
    await Provider.of<DatabaseProvider>(context, listen:false).init();
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
              child: LoadingIndicator(),
            );

          if (snapshot.hasData) {
            bool _x = snapshot.data;
            if (_x)
              return SourcesPage();
            else
              return Landing();
          } else
            return Center(
              child: Text(
                "Start Up Error\n ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
        });
  }
}
