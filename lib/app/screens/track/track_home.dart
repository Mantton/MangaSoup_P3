import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/screens/mangadex/mangadex_home.dart';
import 'package:mangasoup_prototype_3/app/screens/track/mal/mal_screen.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List names = ['MangaDex', "MyAnimeList"];
    List pages = [DexHubHome(), MALHome()];
    List images = ["mangadex.png", "mal.png"];
    return Scaffold(
      appBar: AppBar(
        title: Text("Services"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView.separated(
          itemBuilder: (_, index) => ListTile(
            tileColor: Color.fromRGBO(6, 6, 6, 1.0),
            title: Text(
              names[index],
              style: notInLibraryFont,
            ),
            leading: Image.asset("assets/images/${images[index]}"),
            trailing: Icon(
              CupertinoIcons.forward,
              color: Colors.white,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => pages[index],
              ),
            ),
          ),
          separatorBuilder: (_, index) => SizedBox(
            height: 4,
          ),
          itemCount: names.length,
        ),
      ),
    );
  }
}
