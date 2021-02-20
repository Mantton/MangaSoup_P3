import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/ImageSearch.dart';
import 'package:mangasoup_prototype_3/app/screens/browse/imgur_search.dart';
import 'package:mangasoup_prototype_3/app/screens/mangadex/mangadex_home.dart';
import 'package:mangasoup_prototype_3/app/screens/settings/settings_home.dart';
import 'package:mangasoup_prototype_3/app/screens/track/track_home.dart';

class MoreHomePage extends StatelessWidget {
  final List titles = [
    "Settings",
    "MangaDex Home",
    "MangaDex Image Search",
    "Imgur Album Search",
    "Tracking Services"
  ];
  final List icons = [
    "assets/images/icon.png",
    "assets/images/mangadex.png",
    "assets/images/detective.png",
    "assets/images/imgur.png",
    "assets/images/tracking.gif",
  ];
  final List pages = [
    SettingsHome(),
    DexHubHome(),
    ImageSearchPage(),
    ImgurAlbumPage(),
    TrackingServicesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Center(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: titles.length,
            separatorBuilder: (context, index) => SizedBox(
              height: 10,
            ),
            itemBuilder: (_, int index) => ListTile(
              tileColor: Color.fromRGBO(5, 5, 5, 1.0),
              title: Text(
                titles[index],
                style: TextStyle(
                  fontFamily: "Lato",
                  color: Colors.white,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
              ),
              leading: icons[index] is IconData
                  ? Icon(
                      icons[index],
                      color: Colors.purple,
                    )
                  : Image.asset(icons[index]),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => pages[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
