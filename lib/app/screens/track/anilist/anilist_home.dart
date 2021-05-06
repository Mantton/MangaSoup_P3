import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/anilist_login.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_user.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/services/track/anilist/anilist_api.dart';
import 'package:provider/provider.dart';

class AnilistHome extends StatefulWidget {
  @override
  _AnilistHomeState createState() => _AnilistHomeState();
}

class _AnilistHomeState extends State<AnilistHome> {
  Future<AniListUser> user;

  @override
  void initState() {
    user = AniList().getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AniList"),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: user,
        //testing
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: LoadingIndicator());
          else if (snapshot.hasError)
            return Center(
              child: Text(
                "An Error Occurred",
                style: notInLibraryFont,
              ),
            );
          else if (snapshot.hasData) {
            AniListUser target = snapshot.data;
            return Container(
              child: SingleChildScrollView(
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
                                target.avatar,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            target.username,
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
                      color: Color.fromRGBO(9, 9, 9, 1),
                      margin: EdgeInsets.all(10),
                      child: Text(
                        target.about ?? "",
                        style: notInLibraryFont,
                      ),
                    ),
                    Container(
                      color: Color.fromRGBO(9, 9, 9, 1),
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            target.chaptersRead.toString() + " Chapter(s) Read",
                            style: notInLibraryFont,
                          ),
                          Text(
                            target.volumesRead.toString() + " Volume(s) Read",
                            style: notInLibraryFont,
                          ),
                        ],
                      ),
                    ),
                    SwitchListTile.adaptive(
                      title: Text("Auto Sync Progress"),
                      onChanged: (v) => Provider.of<PreferenceProvider>(context,
                              listen: false)
                          .setMALAutoSync(v),
                      value:
                          Provider.of<PreferenceProvider>(context).malAutoSync,
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
                        await AniList().deleteUser();
                        Navigator.pop(context);
                        setState(() {
                          user = AniList().getCurrentUser();
                        });
                      },
                    )
                  ],
                ),
              ),
            );
          } else
            return Container(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    "You are not logged in",
                    style: notInLibraryFont,
                  ),
                  SizedBox(height: 7),
                  CupertinoButton(
                    child: Text("Log In"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AniListLogin(),
                      ),
                    ).then((value) async {
                      if (value != null) {
                        try {
                          showLoadingDialog(context);
                          await AniList().saveUser(value).then((value) {
                            Navigator.pop(context);
                            setState(() {
                              user = AniList().getCurrentUser();
                            });
                            print("success");
                          });
                        } catch (err) {
                          Navigator.pop(context);
                          showSnackBarMessage("Authorization Failed");
                        }
                      }
                    }),
                  )
                ]),
              ),
            );
        },
      ),
    );
  }
}
