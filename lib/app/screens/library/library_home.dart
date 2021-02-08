import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/enums/collection_sort.dart';
import 'package:mangasoup_prototype_3/app/screens/library/libary_order.dart';
import 'package:mangasoup_prototype_3/app/screens/library/library_search.dart';
import 'package:provider/provider.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibraryHome extends StatefulWidget {
  @override
  _LibraryHomeState createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome>
    with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    bgUpdateStream.stream.listen((event) async {
      print("Bg Update Triggered");
      await Provider.of<DatabaseProvider>(context).init();
      setState(() {});
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) =>
            (provider.comicCollections.length > 0 )
                ? library(provider)
                : emptyLibrary());
  }

  Widget library(DatabaseProvider provider) {
    List<Collection> collections = List.of(provider.collections);
    if (!provider.comicCollections.any((element) => element.collectionId == 1)){
      // If Default Collection has no comics remove from view
      collections.removeWhere((element) => element.id == 1); //Remove Default.
    }
    collections.sort((a, b) => a.order.compareTo(b.order)); // Sort Order
    return DefaultTabController(
      length: collections.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Library"),
          centerTitle: true,
          leading: IconButton(
              icon: Icon(CupertinoIcons.refresh),
              onPressed: () {
                showSnackBarMessage("Checking for updates.");
                provider.checkForUpdates().then((value) {
                  if (value == null)
                    showSnackBarMessage("No Update Enabled Collections.");
                  else if (value == 0)
                    showSnackBarMessage("No new Updates.");
                  else
                    showSnackBarMessage("$value new updates in your Library.");
                });
              }),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.search),
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => LibrarySearch(),
                  fullscreenDialog: true,
                ),
              ),
            ),
            IconButton(
              icon: Icon(CupertinoIcons.square_favorites),
              onPressed: () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => LibraryOrderManagerPage(),
                  fullscreenDialog: true,
                ),
              ),
            ),
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
                    List.of(provider.getCollectionComics(collection.id));

                // Sort
                collectionComics = sortComicCollection(
                    collection.librarySort, collectionComics);
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
                                          fontFamily: "lato",
                                        ),
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
                                        onPressed: () {
                                          print(collection.order);
                                        },
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
                                        onPressed: () => provider
                                            .toggleCollectionUpdate(collection),
                                      ),
                                      SizedBox(width: 5.w),
                                      InkWell(
                                        child: Text(
                                          "Sort by\n${collectionSortNames[collection.librarySort]}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontSize: 15.sp,
                                            fontFamily: "lato",
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        onTap: () => idg(collection, provider),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Text(
                "Your Library is currently empty.",
                style: notInLibraryFont,
              ),
            ),
            FlatButton(
              color: Colors.purple,

              onPressed: (){
                // From MangaDex
                // From MangaSoup Tracking
              },
              child: Text("Import"),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey[900])
              ),

            ),
          ],
        ),
      ),
    );
  }

  idg(Collection collection, DatabaseProvider provider) =>
      showPlatformModalSheet(
        context: context,
        builder: (_) => PlatformWidget(
          material: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
          ),
          cupertino: (_, __) => CupertinoActionSheet(
            title: Text("Collection Sort"),
            cancelButton: CupertinoActionSheetAction(
              child: Text("Cancel"),
              isDestructiveAction: true,
              onPressed: () => Navigator.pop(context),
            ),
            actions: List.generate(
              Sort.values.length,
              (index) => CupertinoActionSheetAction(
                onPressed: () {
                  collection.librarySort = index;
                  provider.updateCollection(collection);
                  Navigator.pop(context);
                },
                child: Text(
                  collectionSortNames[index],
                ),
              ),
            ),
          ),
        ),
      );

  @override
  bool get wantKeepAlive => true;
}
