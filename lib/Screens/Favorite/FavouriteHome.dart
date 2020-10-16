import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavouritePage extends StatefulWidget {
  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.refresh),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(CupertinoIcons.search),
            onPressed: () {},
          )
        ],
      ),
      backgroundColor: Colors.black,
    );
  }
}
