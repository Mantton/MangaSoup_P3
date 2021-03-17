import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/mangadex_login.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Services/mangadex_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/data/mangadex/models/mangadex_profile.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DexHubHome extends StatefulWidget {
  @override
  _DexHubHomeState createState() => _DexHubHomeState();
}

class _DexHubHomeState extends State<DexHubHome> {
  Future<DexProfile> profile;

  Future<DexProfile> get() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();

    // Check if cookies are null
    String md_cookies = _prefs.get("mangadex_cookies");
    if (md_cookies == null) return null;

    try {
      // get profile
      return DexProfile.fromMap(
          jsonDecode(_prefs.getString(PreferenceKeys.MANGADEX_PROFILE)));
    } catch (err) {
      // if error occurs the profile might not be saved so retry;
      try {
        return await ApiManager().getMangadexProfile();
      } catch (err) {
        throw err;
      }
    }
  }

  @override
  void initState() {
    profile = get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MangaDex"),
      ),
      body: FutureBuilder(
        future: profile,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: LoadingIndicator(),
            );
          else if (snapshot.hasError)
            return Scaffold(
              body: Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      profile = ApiManager().getMangadexProfile();
                    });
                  },
                  child: Text(
                    "An Error Occurred\n${snapshot.error}\nTap to Retry",
                    style: notInLibraryFont,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          else if (snapshot.hasData)
            return Container(
              child: Column(
                children: [
                  Container(
                    color: Color.fromRGBO(9, 9, 9, 1),
                    margin: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          width: 140,
                          height: 150,
                          padding: EdgeInsets.all(5),
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[900],
                            backgroundImage: CachedNetworkImageProvider(
                                snapshot.data.avatar),
                          ),
                        ),
                        Text(
                          snapshot.data.username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            fontFamily: "lato",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: ListTile(
                      title: Text(
                        "Merge Follow Library",
                        style: notInLibraryFont,
                      ),
                      trailing: Icon(
                        CupertinoIcons.folder_badge_plus,
                        color: Colors.purple,
                      ),
                      onTap: () async => await merge(),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Refresh",
                      style: notInLibraryFont,
                    ),
                    trailing: Icon(
                      Icons.refresh,
                      color: Colors.purple,
                    ),
                    onTap: () {
                      setState(() {
                        profile = ApiManager().getMangadexProfile();
                      });
                    },
                  ),
                  ListTile(
                    title: Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Lato",
                        color: Colors.redAccent,
                      ),
                    ),
                    trailing: Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    onTap: () async {
                      showLoadingDialog(context);
                      try {
                        await DexHub().logout();
                        Navigator.pop(context);
                        setState(() {
                          profile = null;
                        });
                      } catch (err) {
                        Navigator.pop(context);
                        showSnackBarMessage("Error");
                      }
                    },
                  )
                ],
              ),
            );
          else
            return Center(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "No Profile was found\n\n",
                      style: notInLibraryFont,
                      textAlign: TextAlign.center,
                    ),
                    CupertinoButton.filled(
                      child: Text("Login"),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MangaDexLogin(),
                        ),
                      ).then(
                        (value) {
                          setState(() {
                            profile = get();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
        },
      ),
    );
  }

  merge() async {
    showLoadingDialog(context);
    try {
      List<ComicHighlight> highlights =
          await ApiManager().getMangaDexUserLibrary();
      Map<String, List<ComicHighlight>> sorted = groupBy(
        highlights,
        (ComicHighlight obj) => obj.mangadexFollowType,
      );
      Navigator.pop(context);
      mergeIntoMangaSoupLibrary(sorted);
    } catch (err) {
      Navigator.pop(context);
      showSnackBarMessage("Merge Failed", error: true);
    }
  }

  mergeIntoMangaSoupLibrary(Map<String, List<ComicHighlight>> map) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        content: Text(
          "This would also overwrite predefined collections IF the comic already exists in your library",
        ),
        cupertino: (_, __) => CupertinoAlertDialogData(
          title: Text("Merge to Local Library"),
          content: Text(
            "This would also overwrite predefined collections IF the comic already exists in your library",
          ),
        ),
        actions: [
          PlatformDialogAction(
              child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
          PlatformDialogAction(
              child: Text("Proceed"),
              onPressed: () async {
                Navigator.pop(context);
                mergeLogic(context, map);
              }),
        ],
      ),
    );
  }

  mergeLogic(
      BuildContext context, Map<String, List<ComicHighlight>> sorted) async {
    try {
      showLoadingDialog(context);
      for (MapEntry<String, List<ComicHighlight>> entry
          in sorted.entries.map((e) => e)) {
        String collectionName = entry.key;
        List<ComicHighlight> highlights = entry.value;

        Collection collection;
        try {
          collection = Provider.of<DatabaseProvider>(context, listen: false)
              .collections
              .firstWhere((element) =>
                  element.name.toLowerCase() == collectionName.toLowerCase());
          print("Collection matching $collectionName found");
        } catch (err) {
          print("No Collection matching $collectionName found creating new...");
          collection =
              await Provider.of<DatabaseProvider>(context, listen: false)
                  .createCollection(collectionName);
        }
        if (collection != null) {
          // Collection Exists, add comics and save to collection
          for (ComicHighlight highlight in highlights) {
            Comic comic = Comic(
                title: highlight.title,
                link: highlight.link,
                thumbnail: highlight.thumbnail,
                referer: highlight.imageReferer,
                source: highlight.source,
                sourceSelector: highlight.selector,
                chapterCount: 0);

            // Save/ Update Comic
            int id = await Provider.of<DatabaseProvider>(context, listen: false)
                .evaluate(comic, overWriteChapterCount: false);
            // Set Collection
            await Provider.of<DatabaseProvider>(context, listen: false)
                .addToLibrary([collection], id);
          }
        }
      }

      Navigator.pop(context);
      showMessage(
          "Merge Complete", CupertinoIcons.folder, Duration(seconds: 1));
    } catch (err) {
      print(err);
      Navigator.pop(context);
      showMessage("An Error Occurred", CupertinoIcons.exclamationmark_circle,
          Duration(seconds: 2));
    }
  }
}
