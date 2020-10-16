import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/Sources/Sources.dart';
import 'package:mangasoup_prototype_3/landing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
