import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/library/library_settings.dart';
import 'package:provider/provider.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibraryHome extends StatefulWidget {
  @override
  _LibraryHomeState createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) =>
            (provider.collections.length > 1)
                ? library(provider)
                : emptyLibrary());
  }

  Widget library(DatabaseProvider provider) {
    List<Collection> collections = List.of(provider.collections);
    collections.removeWhere((element) => element.order == 0); //Remove Default.
    collections.sort((a, b) => a.order.compareTo(b.order)); // Sort Order
    return DefaultTabController(
      length: collections.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Library"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.refresh),
            onPressed: null, // todo, check for updates
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: null, //todo, search library
            ),
            IconButton(
                icon: Icon(Icons.format_list_numbered_rtl_outlined),
                onPressed: () => Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => LibrarySettings(),
                        fullscreenDialog: true,
                      ),
                    ))
          ],
          bottom: TabBar(
            indicatorColor: Colors.purpleAccent,
            isScrollable: true,
            unselectedLabelStyle: TextStyle(fontSize: 19.sp),
            labelStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            tabs: List<Widget>.generate(collections.length, (index) {
              return Tab(
                text: collections[index].name,
              );
            }),
          ),
        ),
        extendBodyBehindAppBar: false,
        body: SafeArea(
          child: TabBarView(
            children: List.generate(
              collections.length,
              (index) {
                Collection collection = collections[index];
                List<Comic> collectionComics =
                    provider.getCollectionComics(collection.id);
                // Prepare Comics
                return Stack(
                  children: <Widget>[
                    NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            floating: true,
                            snap: false,
                            pinned: false,
                            bottom: PreferredSize(
                              preferredSize: Size(0, 10),
                              child: Padding(
                                padding: EdgeInsets.all(8.w),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${collectionComics.length} Comic${collectionComics.length > 1 || collectionComics.length == 0 ? "s" : ''} in Collection",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 15.sp,
                                            fontFamily: "lato"),
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Center(
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.amber,
                                            // size: 35,
                                          ),
                                        ),
                                        onPressed: null,
                                      ),
                                      SizedBox(width: 5.w),
                                      IconButton(
                                        icon: Center(
                                          child: Icon(
                                            collection.updateEnabled
                                                ? Icons
                                                    .notifications_active_outlined
                                                : Icons
                                                    .notifications_off_outlined,
                                            // size: 35,
                                          ),
                                        ),
                                        color: collection.updateEnabled
                                            ? Colors.green
                                            : Colors.red,
                                        onPressed: null,
                                      ),
                                      SizedBox(width: 10.w),
                                      InkWell(
                                        child: Text(
                                          "Sort",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 17.sp,
                                              fontFamily: "lato"),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ];
                      },
                      body: Container(
                        child: ComicGrid(
                          comics: collectionComics
                              .map((e) => e.toHighlight())
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget emptyLibrary() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Library"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Text(
            "Your Library is currently empty",
            style: isEmptyFont,
          ),
        ),
      ),
    );
  }
}
