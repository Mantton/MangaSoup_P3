import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/ImageSearch.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/ImgurSearch.dart';
import 'package:mangasoup_prototype_3/Screens/MangaDex/DexLogin.dart';
import 'package:mangasoup_prototype_3/Screens/Testing.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/env1.dart';

import '../Settings/Settings.dart';

class MorePage extends StatefulWidget {
  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  List titles = [
    "All Tags",
    "Settings",
    "Testing",
    "MangaSoup Discussions",
    "ID Search",
    "Image Search",
    "Imgur Album",
    "Admin Blogs"
  ];
  String _selector;

  List pages = [
    EmbeddedPageViewTest(),
    SettingsPage(),
    Testing(),
    MangadexLoginPage(),
    SettingsPage(),
    ImageSearchPage(),
    ImgurAlbumPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("More"),
        centerTitle: true,
      ),
      body: Container(
        child: GridView.builder(
            itemCount: titles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 15.h,
              crossAxisSpacing: 15.w,
              childAspectRatio: .80,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => pages[index],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: GridTile(
                    child: Container(
                      color: Colors.blue[(index + 1) * 100],
                    ),
                    footer: Container(
                      color: Colors.black54,
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w),
                        child: Center(
                          child: Text(
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
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
