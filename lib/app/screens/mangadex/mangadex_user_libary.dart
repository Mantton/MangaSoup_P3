import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:collection/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:provider/provider.dart';

class MangaDexUserLibrary extends StatefulWidget {
  @override
  _MangaDexUserLibraryState createState() => _MangaDexUserLibraryState();
}

class _MangaDexUserLibraryState extends State<MangaDexUserLibrary> {
  Future<List<ComicHighlight>> userLibrary;
  Future<List<ComicHighlight>> init() async {
    return await ApiManager().getMangaDexUserLibrary();
  }

  @override
  void initState() {
    userLibrary = init();
    super.initState();
    print("done");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: userLibrary,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: LoadingIndicator());
        else if (snapshot.hasData) {
          Map<String, List<ComicHighlight>> sorted = groupBy(
            snapshot.data,
            (ComicHighlight obj) => obj.mangadexFollowType,
          );
          return DefaultTabController(
            length: sorted.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text("User Library"),
                actions: [
                  IconButton(
                      icon: Icon(CupertinoIcons.arrow_merge),
                      onPressed: () => mergeIntoMangaSoupLibrary(sorted))
                ],
                bottom: TabBar(
                  indicatorColor: Colors.purple,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: TextStyle(
                      fontFamily: "Roboto",
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                  isScrollable: true,
                  tabs: List.generate(
                    sorted.length,
                    (index) => Tab(
                      text: sorted.keys.toList()[index],
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: List.generate(
                    sorted.length,
                    (index) => Container(
                          child: ComicGrid(
                            comics: sorted.values.toList()[index],
                          ),
                        )),
              ),
            ),
          );
        } else if (snapshot.hasError)

          return Scaffold(
            body: Center(
              child: InkWell(
                child: Text(
                  "An Error Occurred\nTap to go back\n${snapshot.error}",
                  style: notInLibraryFont,
                  textAlign: TextAlign.center,
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          );
        else
          return Center(
            child: Text("Hmm... you shouldn't be seeing this"),
          );
      },
    );
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
      for (MapEntry<String, List<ComicHighlight>> entry in sorted.entries.map((e) => e)){
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
