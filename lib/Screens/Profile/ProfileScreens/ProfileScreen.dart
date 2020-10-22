import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:mangasoup_prototype_3/Providers/HighlIghtProvider.dart';
import 'package:provider/provider.dart';

class ProfilePageScreen extends StatefulWidget {
  final ComicProfile comicProfile;

  const ProfilePageScreen({Key key, @required this.comicProfile})
      : super(key: key);

  @override
  _ProfilePageScreenState createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  ComicProfile profile;
  TextStyle def = TextStyle(
    color: Colors.white,
    fontSize: 15.sp,
  );
  bool isExpanded = false;
  FavoritesManager _favoritesManager = FavoritesManager();
  Favorite favoriteObject;
  bool _isFav = false;
  List _collections;
  Future<bool> init;

  Future<bool> initializeProfile() async {
    profile = widget.comicProfile;
    favoriteObject = await _favoritesManager.isFavorite(profile.link);

    // Check if Favorite
    if (favoriteObject == null) {
      _isFav = false;
    } else
      _isFav = true;
    // Get Active Collections

    _collections = await _favoritesManager.getCollections();
    debugPrint(_collections.toString());
    return true;
  }

  @override
  void initState() {
    super.initState();
    init = initializeProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text("MangaSoup Encountered a Critical Error");
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
                  chapterPreview(),
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
          margin: EdgeInsets.only(top: 10.h),
          width: 130.h,
          height: 190.h,
          child: Image.network(profile.thumbnail),
        ),
        SizedBox(
          width: 10.w,
        ),
        Expanded(
          child: Container(
            height: 220.h,
            padding: EdgeInsets.all(10.w),
            margin: EdgeInsets.only(top: 10.h),
//                                          color: Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  profile.title,
                  style: TextStyle(
                      color: Colors.white, fontSize: 27.sp, fontFamily: 'Lato'),
                  maxLines: 2,
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
                    style: def,
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
            onPressed: action),
        Text(
          actionText,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  /// Actions
  removeFromLibrary() async {
    var x = await _favoritesManager.deleteByID(favoriteObject.id);
    debugPrint(x.toString());
    setState(() {
      _isFav = false;
    });
    Navigator.pop(context);
    showMessage(
      "Removed!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  inFavorites() {
    return showPlatformModalSheet(
        context: context,
        builder: (_) => PlatformWidget(
              material: (_, __) => ListView(
                children: [
                  ListTile(
                    title: Text("Remove from Library"),
                    onTap: () async {
                      removeFromLibrary();
                    },
                  ),
                  ListTile(
                    title: Text("Move to different Collection"),
                    onTap: () {
                      moveToDifferentCollection();
                      //todo, move to different collection
                    },
                  )
                ],
              ),
              cupertino: (_, __) => CupertinoActionSheet(
                title: Text("Options"),
                cancelButton: CupertinoButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () async {
                      removeFromLibrary();
                    },
                    child: Text("Remove from Library"),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () {
                      moveToDifferentCollection();
                    },
                    child: Text("Move to different Collection"),
                  )
                ],
              ),
            ));
  }

  move(int index) async {
    favoriteObject.collection = _collections[index];
    int q = await _favoritesManager.updateByID(favoriteObject);
    setState(() {});
    Navigator.pop(context);
    showMessage(
      "Moved to ${_collections[index]}!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  moveToDifferentCollection() {
    Navigator.pop(context);
    return showPlatformModalSheet(
      context: context,
      builder: (_) => PlatformWidget(
        material: (_, __) => Container(
          child: Column(
            children: List<Widget>.generate(
              _collections.length,
              (index) => ListTile(
                title: Text(_collections[index]),
                onTap: () async {
                  await move(index);
                },
              ),
            ),
          ),
        ),
        cupertino: (_, __) => CupertinoActionSheet(
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
              children: List<CupertinoActionSheetAction>.generate(
                _collections.length,
                (index) => CupertinoActionSheetAction(
                  onPressed: () async {
                    await move(index);
                  },
                  child: Text(
                    _collections[index],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Favorite> addToFavorites(String collectionName) async {
    Favorite newFav = Favorite(
        null,
        Provider.of<ComicHighlightProvider>(context, listen: false).highlight,
        collectionName,
        profile.chapterCount,
        0);
    return await _favoritesManager.save(newFav);
  }

  add(int index) async {
    favoriteObject = await addToFavorites(_collections[index]);
    setState(() {
      _isFav = true;
    });
    Navigator.pop(context);
    showMessage(
      "Added to ${_collections[index]}!",
      Icons.check,
      Duration(
        milliseconds: 1000,
      ),
    );
  }

  notInFavorites() {
    return showPlatformModalSheet(
      context: context,
      builder: (_) => PlatformWidget(
        material: (_, __) => Container(
          child: Column(
            children: [
              Column(
                children: List<Widget>.generate(
                  _collections.length,
                  (index) => ListTile(
                    title: Text(_collections[index]),
                    onTap: () async {
                      await add(index);
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text("Create New Collection"),
                onTap: () async {
                  Navigator.pop(context);
                  await createCollection();
                },
              )
            ],
          ),
        ),
        cupertino: (_, __) => CupertinoActionSheet(
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
                    (index) => CupertinoActionSheetAction(
                      onPressed: () async {
                        await add(index);
                      },
                      child: Text(
                        _collections[index],
                      ),
                    ),
                  ),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    createCollection();
                    Navigator.pop(context);
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

  createCollection() {
    String newCollectionName = "";
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Create New Collection"),
        content: Column(
          children: [
            Text("Name this Collection"),
            PlatformTextField(
              maxLength: 20,
              cursorColor: Colors.purple,
              onChanged: (val) => newCollectionName = val,
            )
          ],
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
                  favoriteObject = await addToFavorites(newCollectionName);
                  setState(() {
                    _isFav = true;
                  });
                  Navigator.pop(context);
                  showMessage(
                    "Added to $newCollectionName}!",
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

  Widget comicActions() {
    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Row(
        children: [
          actionButton(Icons.play_arrow, "Read", null),
          Spacer(),
          actionButton(Icons.list, "Chapters", null),
          Spacer(),
          actionButton(
            _isFav ? Icons.favorite : Icons.favorite_border,
            _isFav ? "In Library\n${favoriteObject.collection}" : "Favorite",
            _isFav ? inFavorites : notInFavorites,
          )
        ],
      ),
    );
  }

  Widget profileBody() {
    return Container(
      decoration: BoxDecoration(
//                              color: Colors.grey[900],
//                        borderRadius: BorderRadius.circular(30)
          ),
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
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  )),
              isExpanded
                  ? Container()
                  : InkWell(
                      child: Text(
                        'more',
                        style: TextStyle(
                            color: Colors.purpleAccent, fontSize: 15.sp),
                      ),
                      onTap: () => setState(() => isExpanded = true))
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
                      //todo, push to tag page
                      debugPrint("Push to tag page");
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
                            child: AutoSizeText(
                              profile.genres[index]['Genre'].toString(),
                              maxLines: 2,
                              softWrap: true,
                              wrapWords: false,
                              minFontSize: 5.sp,
                              maxFontSize: 100.sp,
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

  Widget chapterPreview() {
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
                  "Chapters",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    // todo push to downloads page
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    size: 30.w,
                  ),
                )
              ],
            ),
          ),
          Column(
            children: [
              Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: displayChapters(profile.chapterCount),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 50.h,
                          child: ListTile(
                            title: Text(
                              profile.chapters[index]['Chapter'],
                            ),
                            trailing: Text(
                              profile.chapters[index]['Date'] ?? "",
                            ),
                          ),
                        ),
                      );
                    }),
              ),
              GestureDetector(
                onTap: () {
                  // todo, push to all chapters page
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
                            style: TextStyle(
                                color: Colors.purple, fontSize: 20.sp),
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.all(15.w),
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            'No available chapters',
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
          )
        ],
      ),
    );
  }

  displayChapters(int length) {
    if (length > 5)
      return 5;
    else
      return length;
  }
}
