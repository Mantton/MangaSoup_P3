import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:mangasoup_prototype_3/Models/Misc.dart';
import 'package:mangasoup_prototype_3/Providers/ComicHistoryProvider.dart';
import 'package:mangasoup_prototype_3/Providers/FavoriteProvider.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/AllChapters.dart';
import 'package:mangasoup_prototype_3/Screens/Profile/DownloadChapters.dart';
import 'package:mangasoup_prototype_3/Screens/Tags/TagComics.dart';
import 'package:provider/provider.dart';

class ProfilePageScreen extends StatefulWidget {
  final ComicProfile comicProfile;
  final ComicHighlight highlight;

  const ProfilePageScreen(
      {Key key, @required this.comicProfile, @required this.highlight})
      : super(key: key);

  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen>
    with AutomaticKeepAliveClientMixin {
  ComicProfile profile;
  TextStyle def = TextStyle(
    color: Colors.white,
    fontSize: 18.sp,
  );
  bool isExpanded = false;

  Future<bool> init;

  Future<bool> initializeProfile() async {
    var provider = Provider.of<FavoriteProvider>(context, listen: false);
    Favorite favoriteObject;
    profile = widget.comicProfile;
    favoriteObject = await provider.returnFavorite(profile.link);

    /// Check if Favorite
    if (favoriteObject == null) {
      // not in favorites
    } else {
      // In favorites
      /// Update Chapter Count
      if (!widget.comicProfile.containsBooks)
        favoriteObject.chapterCount = widget.comicProfile.chapterCount;
      else {
        int chapterCount = 0;
        for (Map bk in widget.comicProfile.books) {
          Book book = Book.fromMap(bk);
          chapterCount += book.generatedLength;
        }
        favoriteObject.chapterCount = chapterCount;
      }

      /// Reset Update Count
      favoriteObject.updateCount = 0;
      favoriteObject.highlight.thumbnail =
          widget.comicProfile.thumbnail; // Update Favorites Thumbnails
      await provider.update(favoriteObject);
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    init = initializeProfile();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: init,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text(
              "MangaSoup Encountered a Critical Error \n ${snapshot.error}",
              textAlign: TextAlign.center,
            );
          }
          if (snapshot.hasData) {
            return homeView();
          } else {
            return Text("MangaSoup Encountered a Critical Error");
          }
        });
  }

  Widget homeView() {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  profileHeader(),
                  Divider(
                    height: 20.h,
                    indent: 5.w,
                    endIndent: 5.w,
                    color: Colors.white12,
                    thickness: 2,
                  ),
                  comicActions(),
                  profileBody(),
                  contentPreview()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget profileHeader() {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10.h, left: 10.w),
          width: 180.h,
          height: 250.h,
          child: SoupImage(
            url: profile.thumbnail,
            referer: widget.highlight.imageReferer,
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: Container(
            // height: 220.h,
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.only(top: 10.h),
//                                          color: Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SelectableText(
                  profile.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontFamily: 'Lato',
                  ),
                  // maxLines: 3,
                ),
                Divider(
                  height: 20.h,
                  indent: 5.w,
                  endIndent: 5.w,
                  color: Colors.white12,
                  thickness: 2,
                ),
                FittedBox(
                  child: Text(
                      "By ${profile.author.toString().replaceAll("[", "").replaceAll("]", '')}",
                      style: def),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    profile.status,
                    style: TextStyle(
                      color: (profile.status.toLowerCase().contains("complete"))
                          ? Colors.green
                          : (profile.status.toLowerCase().contains("on"))
                              ? Colors.blue
                              : Colors.redAccent,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    "Art by " +
                        profile.artist
                            .toString()
                            .replaceAll("[", "")
                            .replaceAll("]", ''),
                    style: def,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                FittedBox(
                  child: Text(
                    "Source: " + profile.source,
                    style: def,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget actionButton(IconData icon, String actionText, Function action) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Colors.purpleAccent,
          ),
          iconSize: 30.w,
          onPressed: () => action,
        ),
        Text(
          actionText,
          textAlign: TextAlign.center,
          style: def,
        )
      ],
    );
  }

  Widget comicActions() {
    return Consumer<ComicDetailProvider>(builder: (context, provider, _) {
      return Container(
        margin: EdgeInsets.only(left: 20.w, right: 20.w),
        child: Row(
          children: [
            actionButton(
              Icons.play_arrow,
              (provider.history.lastStop == null) ? "Read" : "Continue",
              null,
            ),
            Spacer(),
            Column(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.dehaze,
                      color: Colors.purpleAccent,
                    ),
                    iconSize: 30.w,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChapterList(
                            chapterList: profile.chapters,
                          ),
                        ),
                      );
                    }),
                Text(
                  "Chapters",
                  textAlign: TextAlign.center,
                  style: def,
                )
              ],
            ),
            Spacer(),
            Consumer<FavoriteProvider>(builder: (context, provider, _) {
              bool isFavorite =
                  provider.isFavorite(widget.comicProfile.link) ? true : false;
              Favorite fav;
              if (isFavorite) {
                fav = provider.returnFavorite(widget.comicProfile.link);
              } else
                fav = null;

              /// Collection
              return Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.purpleAccent,
                    ),
                    iconSize: 30.w,
                    onPressed: () => isFavorite
                        ? inFavorites(favorite: fav)
                        : notInFavorites(favorite: fav),
                  ),
                  Text(
                    isFavorite ? "${fav.collection}" : "Add",
                    textAlign: TextAlign.center,
                    style: def,
                  )
                ],
              );
            })
          ],
        ),
      );
    });
  }

  Widget profileBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5,
            ),
            Text(
              'Description',
              style: TextStyle(color: Colors.white, fontSize: 25.sp),
            ),
            SizedBox(
              height: 5,
            ),

            Column(children: <Widget>[
              ConstrainedBox(
                  constraints: isExpanded
                      ? BoxConstraints()
                      : BoxConstraints(maxHeight: 50.0.h),
                  child: Text(
                    profile.description,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.grey, fontSize: 15.sp),
                  )),
              isExpanded
                  ? Container()
                  : Center(
                      child: InkWell(
                        child: Text(
                          'More',
                          style: TextStyle(
                            color: Colors.purpleAccent,
                            fontSize: 15.sp,
                          ),
                        ),
                        onTap: () => setState(
                          () => isExpanded = true,
                        ),
                      ),
                    )
            ]),
            SizedBox(
              height: 5.h,
            ),
            Text(
              'Genres',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            SizedBox(
              height: 5.h,
            ),
            // data['Genre(s)'].toString(),
            GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1.7,
                ),
                itemCount: profile.genres.length,
                itemBuilder: (BuildContext context, int index) {
//                                debugPrint(data['Genre(s)'][index]['Genre']);
                  return GestureDetector(
                    onTap: () {
                      // push to tag page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TagComicsPage(
                              tag: Tag.fromMap(profile.genres[index])),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(4.0.w),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(5.w)),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: Text(
                              profile.genres[index]['tag'].toString(),
                              maxLines: 2,
                              softWrap: true,
                              // wrapWords: false,
                              // minFontSize: 5.sp,
                              // maxFontSize: 100.sp,
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget contentPreview() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
              8.w,
            ),
            child: Row(
              children: [
                Text(
                  (!profile.containsBooks) ? "Chapters" : "Chapter Collections",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: (!profile.containsBooks)
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DownloadChaptersPage(
                                chapterList: profile.chapters,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    CupertinoIcons.cloud_download,
                    size: 30.w,
                    color: Colors.purple,
                  ),
                )
              ],
            ),
          ),
          (!profile.containsBooks) ? containsChapters() : containsBooks()
        ],
      ),
    );
  }

  Widget containsChapters() {
    return Column(
      children: [
        Consumer<ComicDetailProvider>(builder: (context, provider, _) {
          List readChapterNames = [];
          List readChapterLinks = [];
          if (provider.history.readChapters != null) {
            readChapterNames =
                provider.history.readChapters.map((m) => m['name']).toList() ??
                    [];
            readChapterLinks =
                provider.history.readChapters.map((m) => m['link']).toList() ??
                    [];
          }
          return Container(
            child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: displayChapters(profile.chapterCount),
                itemBuilder: (BuildContext context, int index) {
                  Chapter chapter = Chapter.fromMap(profile.chapters[index]);
                  bool read = (readChapterNames.contains(chapter.name) ||
                      readChapterLinks.contains(chapter.link));
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 70.h,
                      child: ListTile(
                        title: Text(
                          chapter.name,
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: (read) ? Colors.grey[700] : Colors.white,
                          ),
                        ),
                        subtitle: chapter.maker.isNotEmpty
                            ? Text(
                                chapter.maker,
                                style: TextStyle(
                                    fontSize: 15.sp, color: Colors.grey[700]),
                              )
                            : null,
                        trailing: Text(
                          chapter.date ?? "",
                          style: TextStyle(
                              color: Colors.grey[700], fontSize: 15.sp),
                        ),
                      ),
                    ),
                  );
                }),
          );
        }),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChapterList(
                  chapterList: profile.chapters,
                ),
              ),
            );
          },
          child: profile.chapterCount != 0
              ? Container(
                  margin: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10)),
                  height: 45.h,
                  child: Center(
                    child: Text(
                      'View all Chapters',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.purple, fontSize: 20.sp),
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.all(15.w),
                  color: Colors.grey[800],
                  child: ListTile(
                    title: Text(
                      widget.highlight.selector != "mangadex"
                          ? 'No available chapters'
                          : "No Available Chapters for your specified Content Language(s)",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget containsBooks() {
    return Column(
      children: [
        Container(
          child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: displayChapters(profile.bookCount),
              itemBuilder: (BuildContext context, int index) {
                Book book = Book.fromMap(profile.books[index]);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterList(
                          chapterList: book.chapters,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 50.h,
                    child: ListTile(
                      title: Text(
                        book.name,
                        style: TextStyle(
                          fontSize: 17.sp,
                        ),
                      ),
                      trailing: Text(
                        book.range ?? "",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  displayChapters(int length) {
    if (length > 5)
      return 5;
    else
      return length;
  }

  /// Actions
  removeFromLibrary(Favorite favorite) async {
    var x = await Provider.of<FavoriteProvider>(context, listen: false)
        .delete(favorite);
    debugPrint(x.toString());
    Navigator.pop(context);
    showMessage(
      "Removed!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  //
  inFavorites({Favorite favorite}) {
    return showPlatformModalSheet(
        context: context,
        builder: (_) =>
            PlatformWidget(
              material: (_, __) =>
                  ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text(
                          "Remove from Library",
                          style: def,
                        ),
                        onTap: () async {
                          await removeFromLibrary(favorite);
                        },
                      ),
                      ListTile(
                        title: Text(
                          "Move to different Collection",
                          style: def,
                        ),
                        onTap: () {
                          moveToDifferentCollection(favorite: favorite);
                        },
                      )
                    ],
                  ),
              cupertino: (_, __) =>
                  CupertinoActionSheet(
                    title: Text("Options"),
                    cancelButton: CupertinoButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      CupertinoActionSheetAction(
                        onPressed: () async {
                          await removeFromLibrary(favorite);
                        },
                        child: Text("Remove from Library"),
                      ),
                      CupertinoActionSheetAction(
                        onPressed: () {
                          moveToDifferentCollection(favorite: favorite);
                        },
                        child: Text("Move to different Collection"),
                      )
                    ],
                  ),
            ));
  }

  //
  move({Favorite fav, String collection}) async {
    fav.collection = collection;
    await Provider.of<FavoriteProvider>(context, listen: false).update(fav);
    setState(() {});
    Navigator.pop(context);
    showMessage(
      "Moved to $collection!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  //
  moveToDifferentCollection({Favorite favorite}) {
    Navigator.pop(context);
    List options =
        Provider
            .of<FavoriteProvider>(context, listen: false)
            .collections;
    options.remove(favorite.collection);
    return showPlatformModalSheet(
      context: context,
      builder: (_) =>
          PlatformWidget(
            material: (_, __) =>
                Container(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      child: Center(
                        child: Text(
                          "Move",
                          style: def,
                        ),
                      ),
                    ),
                    Column(
                      children: List<Widget>.generate(
                        options.length,
                            (index) =>
                            ListTile(
                              title: Text(
                                options[index],
                                style: def,
                              ),
                              onTap: () async {
                                await move(fav: favorite,
                                    collection: options[index]);
                              },
                            ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Create New Collection",
                        style: def,
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await createCollection(favorite: favorite);
                      },
                    )
                  ]),
                ),
            cupertino: (_, __) =>
                CupertinoActionSheet(
                  title: Text(
                    "Add to Collection",
                  ),
                  cancelButton: CupertinoButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Column(
                      children: [
                        Column(
                          children: List<CupertinoActionSheetAction>.generate(
                            options.length,
                                (index) =>
                                CupertinoActionSheetAction(
                                  onPressed: () async {
                                    await move(fav: favorite,
                                        collection: options[index]);
                                  },
                                  child: Text(
                                    options[index],
                                  ),
                                ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          child: Text("Create New Collection"),
                          onPressed: () async {
                            Navigator.pop(context);
                            await createCollection(favorite: favorite);
                          },
                        )
                      ],
                    )
                  ],
                ),
          ),
    );
  }

  Future<Favorite> addToFavorites(
      {String collectionName, Favorite favoriteObject}) async {
    print(
        "Saving : ${Provider
            .of<ComicHighlightProvider>(context, listen: false)
            .highlight
            .link}");
    Favorite newFav = Favorite(
        null,
        Provider
            .of<ComicHighlightProvider>(context, listen: false)
            .highlight,
        collectionName,
        profile.chapterCount,
        0);

    if (favoriteObject == null)
      return await Provider.of<FavoriteProvider>(context, listen: false)
          .add(newFav);
    else {
      favoriteObject.collection = collectionName;
      await Provider.of<FavoriteProvider>(context, listen: false)
          .update(favoriteObject);
      return favoriteObject;
    }
  }

  //
  add({String collection, Favorite favorite}) async {
    await addToFavorites(collectionName: collection, favoriteObject: favorite);
    Navigator.pop(context);
    favoritesStream.add("");
    showMessage(
      "Added to $collection!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  //
  notInFavorites({Favorite favorite}) {
    List _collections =
        Provider
            .of<FavoriteProvider>(context, listen: false)
            .collections;
    return showPlatformModalSheet(
      context: context,
      builder: (_) =>
          PlatformWidget(
            material: (_, __) =>
                Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: List<Widget>.generate(
                          _collections.length,
                              (index) =>
                              ListTile(
                                title: Text(
                                  _collections[index],
                                  style: def,
                                ),
                                onTap: () async {
                                  await add(
                                      collection: _collections[index],
                                      favorite: favorite);
                                },
                              ),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Create New Collection",
                          style: def,
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          await createCollection(favorite: favorite);
                        },
                      )
                    ],
                  ),
                ),
            cupertino: (_, __) =>
                CupertinoActionSheet(
                  title: Text(
                    "Add to Collection",
                  ),
                  cancelButton: CupertinoButton(
                    child: Text(
                      "Cancel",
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Column(
                      children: [
                        Column(
                          children: List<CupertinoActionSheetAction>.generate(
                            _collections.length,
                                (index) =>
                                CupertinoActionSheetAction(
                                  onPressed: () async {
                                    await add(collection: _collections[index]);
                                  },
                                  child: Text(
                                    _collections[index],
                                  ),
                                ),
                          ),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () async {
                            Navigator.pop(context);
                            await createCollection(favorite: favorite);
                          },
                          child: Text(
                            "Create New Collection",
                          ),
                        )
                      ],
                    )
                  ],
                ),
          ),
    );
  }

  //
  createCollection({@required Favorite favorite}) {
    String newCollectionName = "";
    List _collections =
        Provider
            .of<FavoriteProvider>(context, listen: false)
            .collections;
    showPlatformDialog(
      context: context,
      builder: (_) =>
          PlatformAlertDialog(
            title: Text("Create New Collection"),
            content: Container(
              child: PlatformTextField(
                maxLength: 20,
                cursorColor: Colors.purple,
                onChanged: (val) => newCollectionName = val,
              ),
            ),
            actions: [
              PlatformDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              PlatformDialogAction(
                child: Text("OK"),
                onPressed: () async {
                  debugPrint(newCollectionName);
                  if (newCollectionName == null) {
                    showMessage("Invalid Name", Icons.cancel_outlined,
                        Duration(milliseconds: 1000));
                  } else {
                    if (_collections.contains(newCollectionName.trim()) ||
                        newCollectionName == "") {
                      showMessage("Invalid Name", Icons.cancel_outlined,
                          Duration(milliseconds: 1000));
                    } else {
                      await addToFavorites(collectionName: newCollectionName,
                          favoriteObject: favorite);
                      Navigator.pop(context);
                      showMessage(
                        "Added to $newCollectionName!",
                        Icons.check,
                        Duration(
                          milliseconds: 1000,
                        ),
                      );
                    }
                  }
                },
              )
            ],
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
