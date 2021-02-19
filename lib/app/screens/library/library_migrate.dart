import 'package:flutter/material.dart';

class LibraryMigratePage extends StatefulWidget {
  @override
  _LibraryMigratePageState createState() => _LibraryMigratePageState();
}

class _LibraryMigratePageState extends State<LibraryMigratePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Migrate"),
        centerTitle: true,
      ),
      body: Center(
        child: Text("Migrations Coming in Version 0.0.4"),
      ),
    );
  }
}