import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/FavoriteGrid.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Screens/Favorite/FavoriteEdit.dart';
import 'package:mangasoup_prototype_3/Screens/Favorite/FavoruteSearch.dart';

class FavouritePage extends StatefulWidget {
  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  FavoritesManager _manager = FavoritesManager();
  List collections;

  Future<Map> initializer;

  Future<Map> getFavorites() async {
    Map holder = await _manager.getSortedFavorites();
    collections = holder.keys.toList();
    return holder;
  }

  @override
  void initState() {
    super.initState();
    initializer = getFavorites();
    favoritesStream.stream.listen((event) {
      setState(() {
        initializer = getFavorites();
        debugPrint("Favorites Rebuilt!");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializer,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Internal Error"),
            );
          }
          if (snapshot.hasData) if (snapshot.data.length != 0)
            return mainBody(snapshot.data);
          else
            return emptyLibrary();
          else {
            return Text("No Favorites");
          }
        });
  }

  Widget emptyLibrary() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorites"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          child: Text("Your Library is currently empty"),
        ),
      ),
    );
  }

  Widget mainBody(Map comics) {
    return DefaultTabController(
      length: collections.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Favorites"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () async {
                showLoadingDialog(context);
                List<Favorite> favorites = await _manager.getAll();
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FavoriteSearch(
                      favorites: favorites,
                    ),
                  ),
                );
              },
            ),
          ],
          leading: IconButton(
            icon: Icon(CupertinoIcons.refresh),
            onPressed: () {},
          ),
          bottom: TabBar(
            indicatorColor: Colors.purpleAccent,
            isScrollable: true,
            unselectedLabelStyle: TextStyle(fontSize: 19.sp),
            labelStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            tabs: List<Widget>.generate(collections.length, (index) {
              return Tab(
                text: collections[index],
              );
            }),
          ),
        ),
        backgroundColor: Colors.black,
        body: TabBarView(
          children: List<Widget>.generate(collections.length, (index) {
            List<Favorite> collectionComics = comics[collections[index]];
            List<ComicHighlight> highlights = [];
            collectionComics.forEach((element) {
              highlights.add(element.highlight);
            });
            return page(collectionComics, collections[index]);
          }),
        ),
      ),
    );
  }

  Widget page(List<Favorite> comics, String currentCollection) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: 50.h,
            child: Padding(
              padding: EdgeInsets.all(10.0.w),
              child: Row(
                children: [
                  Text(
                    '${comics.length} Manga',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18.sp,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => FavoriteCollectionEdit(
                          favorites: comics,
                          currentCollectionName: currentCollection,
                          collections: collections,

                        ),
                      ),
                    ),
                    color: Colors.purple,
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {},
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          // ComicGrid(comics: comics)
          FavoritesGrid(favorites: comics)
        ],
      ),
    );
  }
}
