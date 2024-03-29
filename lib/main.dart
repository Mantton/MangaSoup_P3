import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart'
    show
        CupertinoDynamicColor,
        CupertinoThemeData,
        DefaultCupertinoLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Providers/BrowseProvider.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/Services/source_manager.dart';
import 'package:mangasoup_prototype_3/Services/update_manager.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/migrate/migrate_home.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:mangasoup_prototype_3/landing.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:workmanager/workmanager.dart';

import 'Providers/migrate_provider.dart';
import 'app/data/database/models/downloads.dart';

const simplePeriodicTask = "simplePeriodicTask";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
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
        updateCount = await _updateManger.checkForUpdateBackGround();
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

        try {
          var connectivityResult = await (Connectivity()
              .checkConnectivity()); //Check if user is connected

          if (connectivityResult == ConnectivityResult.mobile ||
              connectivityResult == ConnectivityResult.wifi) {
            // Only Check for updates with the user connected to a valid network
            updateCount = await _updateManger.checkForUpdateBackGround();
            if (updateCount > 0) {
              if (updateCount == 1)
                showNotification(
                    "$updateCount new update in your library", flp);
              else
                showNotification(
                    "$updateCount new updates in your library", flp);
            }
            stderr.writeln("Done");
          }
        } catch (err) {
          stderr.writeln("ERROR\n$err");
          showNotification("Failed to Update Library", flp);
        }

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

  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: false);
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );

  // await FlutterDownloader.initialize(debug: false); this is causing issues on IOS

  if (Platform.isAndroid) {
    await Workmanager().registerPeriodicTask(
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
        ChangeNotifierProvider(create: (_) => BrowseProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(create: (_) => ReaderProvider()),
        ChangeNotifierProvider(create: (_) => PreferenceProvider()),
        ChangeNotifierProvider(create: (_) => MigrateProvider()),
      ],
      child: App(),
    ),
  );
}

// class App extends StatefulWidget {
//   @override
//   _AppState createState() => _AppState();
// }

class App extends StatelessWidget {
  final Brightness brightness = Brightness.dark;

  @override
  Widget build(BuildContext context) {
    final materialTheme = ThemeData(primaryColor: Colors.black);
    final materialDarkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colors.blueAccent.withOpacity(.8),
      ),
      iconTheme: IconThemeData(color: Colors.blue),
    );
    final cupertinoTheme = CupertinoThemeData(
      brightness: brightness, // if null will use the system theme
      primaryColor: CupertinoDynamicColor.withBrightness(
        color: Colors.blue,
        darkColor: Colors.blue,
      ),
      scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
        color: Colors.black,
        darkColor: Colors.black,
      ),
    );

    return Theme(
      data: brightness == Brightness.light ? materialTheme : materialDarkTheme,
      child: PlatformProvider(
        builder: (_) => PlatformApp(
          cupertino: (_, __) => CupertinoAppData(
            theme: cupertinoTheme,
          ),
          material: (_, __) => MaterialAppData(
            theme: materialDarkTheme,
            darkTheme: materialDarkTheme,
            themeMode: ThemeMode.dark,
          ),
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
          },
          initialRoute: "handler",
          // (_firstRun) ? "sources" : "landing",
          debugShowCheckedModeBanner: false,
          routes: {
            "/": (_) => Landing(),
            "handler": (_) => Handler(),
            "/sources": (_) => SourcesPage(),
            "landing": (_) => Landing(),
            "/migration": (_) => MigrationHome(),
          },
          localizationsDelegates: <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          title: 'MangaSoup',
          navigatorObservers: [BotToastNavigatorObserver()],
        ),
      ),
    );
  }
}

class Handler extends StatefulWidget {
  @override
  _HandlerState createState() => _HandlerState();
}

class _HandlerState extends State<Handler> with AutomaticKeepAliveClientMixin {
  ReceivePort _port = ReceivePort(); // Receiving port for download Isolate

  Future<bool> initSource() async {
    debugPrint("Start Up");
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // Initialize Data Providers
    await Provider.of<DatabaseProvider>(context, listen: false).init();
    await Provider.of<PreferenceProvider>(context, listen: false)
        .loadValues(context);
    SourcePreference _prefs = SourcePreference();
    await _prefs.init();

    // Load Source
    Source source = await _prefs.loadSource();
    if (source == null) {
      debugPrint("Not Initialized");
      return true;
    } else {
      await Provider.of<SourceNotifier>(context, listen: false)
          .loadSource(source);
      if (Provider.of<PreferenceProvider>(context, listen: false)
          .updateOnStartUp)
        Provider.of<DatabaseProvider>(context, listen: false).checkForUpdates();
      return false;
    }
  }

  Future<bool> firstLaunch;

  static void downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('ms_download_send_port');
    send.send([id, status, progress]); // Send Event
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'ms_download_send_port');
    if (!isSuccess) {
      // Failed to bind
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      print("Failed to connect");
      return;
    } else {
      print("MS Download Send Port Connected");
    }
    _port.listen((dynamic data) {
      /*
      * Receives event in for of list [taskId, status, progress]
      * */

      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      TaskInfo task = TaskInfo(taskId: id);
      task.status = status;
      task.progress = progress;
      Provider.of<DatabaseProvider>(context, listen: false)
          .monitorDownloads(task);
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('ms_download_send_port');
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    firstLaunch = initSource();
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Widget build(BuildContext c) {
    super.build(context);
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

  @override
  bool get wantKeepAlive => true;
}
