import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';
import 'package:mangasoup_prototype_3/app/screens/track/anilist/track_result.dart';
import 'package:mangasoup_prototype_3/app/services/track/anilist/anilist_api.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

anilistSearchDialog(
    {@required BuildContext context,
    String initialQuery,
    int comicId,
    int trackId}) {
  showGeneralDialog(
    barrierLabel: "AniList Query Search",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) =>
        anilistDialogBuilder(context, initialQuery, trackId, comicId),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

anilistDialogBuilder(
    BuildContext context, String initialQuery, int trackId, int comicId) {
  return Dialog(
      backgroundColor: Color.fromRGBO(25, 25, 25, 1.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnilistQuery(
          initialQuery: initialQuery,
          comicId: comicId,
        ),
      ));
}

class AnilistQuery extends StatefulWidget {
  final String initialQuery;
  final int comicId;

  const AnilistQuery({Key key, this.initialQuery, this.comicId})
      : super(key: key);

  @override
  _AnilistQueryState createState() => _AnilistQueryState();
}

class _AnilistQueryState extends State<AnilistQuery> {
  Future<List<AniListResult>> results;
  TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: widget.initialQuery);
    results = AniList().queryAnilist(widget.initialQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: TextField(
                controller: _c,
                decoration: mangasoupInputDecoration("Title"),
                onSubmitted: (q) {
                  setState(() {
                    results = AniList().queryAnilist(q);
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
                future: results,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data.length > 0
                        ? ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) => InkWell(
                              onTap: () async {
                                try {
                                  showLoadingDialog(context);
                                  AnilistDetailedResponse r = await AniList()
                                      .getLibraryManga(snapshot.data[index].id);
                                  // Add tracker using provider object;
                                  await Provider.of<DatabaseProvider>(context,
                                          listen: false)
                                      .addTracker(r, widget.comicId);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                } catch (err) {
                                  Navigator.pop(context);
                                  print(err);
                                  showSnackBarMessage("An Error Occurred");
                                }
                              },
                              child: Card(
                                color: Colors.grey[900],
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: Container(
                                          height: 150,
                                          width: 100,
                                          child: SoupImage(
                                            url: snapshot.data[index].thumbnail,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              snapshot.data[index].title,
                                              style: notInLibraryFont,
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            AutoSizeText(
                                              "Status: " +
                                                  getAniPublishStatus(snapshot
                                                          .data[index].status ??
                                                      ''),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            separatorBuilder: (_, index) => SizedBox(
                              height: 3,
                            ),
                            itemCount: snapshot.data.length,
                          )
                        : Center(
                            child: Text("No Comics Found"),
                          );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting)
                    return Center(
                      child: LoadingIndicator(),
                    );
                  else if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          snapshot.error.toString(),
                          style: notInLibraryFont,
                        ),
                      ),
                    );
                  } else
                    return Container();
                }),
          ),
          Center(
            child: MaterialButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
              color: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          )
        ],
      ),
    );
  }
}
