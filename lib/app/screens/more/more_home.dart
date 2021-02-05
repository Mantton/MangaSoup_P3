import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/ImageSearch.dart';
import 'package:mangasoup_prototype_3/app/screens/browse/imgur_search.dart';
import 'package:mangasoup_prototype_3/Screens/Settings/Settings.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MoreHomePage extends StatelessWidget {
  final List titles = [
    "Settings",
    "Image Search",
    "Imgur Album",
  ];
  final List pages = [
    SettingsPage(),
    ImageSearchPage(),
    ImgurAlbumPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Center(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: titles.length,
            itemBuilder: (_, int index) => ListTile(
              title: Text(
                titles[index],
                style: TextStyle(
                    fontFamily: "Roboto",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 7.0,
                        color: Colors.black,
                      ),
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black,
                      )
                    ]),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
              ),
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
