import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/landing.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      title: 'MangaSoup Prototype 3',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            color: Colors.black,
          )),
      debugShowCheckedModeBanner: false,
      routes: {
        "/sources": (_) => SourcesPage(),
      },
      home: Landing(),
    );
  }
}
