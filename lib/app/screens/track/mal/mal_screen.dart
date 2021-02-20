import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/mal_login.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/mal_user.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/services/track/myanimelist/mal_api_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MALHome extends StatefulWidget {
  @override
  _MALHomeState createState() => _MALHomeState();
}

class _MALHomeState extends State<MALHome> {
  Future<MALUser> user;

  @override
  void initState() {
    user = MALManager().getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MyAnimeList"),
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
              child: Text("${snapshot.error}"),
            );
          else if (snapshot.hasData) {
            MALUser target = snapshot.data;
            return Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[900],
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            width: 140,
                            height: 150,
                            padding: EdgeInsets.all(5),
                            child: SoupImage(
                              url: target.avatar,
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
                        CupertinoIcons.clear,
                        color: Colors.redAccent,
                      ),
                      onTap: () async {
                        showLoadingDialog(context);
                        await Provider.of<DatabaseProvider>(context,
                                listen: false)
                            .deleteAllTrackers();
                        try {
                          SharedPreferences _p =
                              await SharedPreferences.getInstance();
                          await _p.remove(PreferenceKeys.MAL_AUTH);
                          Navigator.pop(context);
                          setState(() {
                            user = MALManager().getUserInfo();
                          });
                        } catch (err) {
                          Navigator.pop(context);
                          showSnackBarMessage("An Error Occurred");
                        }
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
                  Text("You are not logged in"),
                  SizedBox(height: 7),
                  CupertinoButton(
                    child: Text("Log In"),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MALLogin(),
                      ),
                    ).then((value) async {
                      if (value != null) {
                        String authCode = value[0];
                        String verifier = value[1];
                        try {
                          showLoadingDialog(context);
                          await MALManager()
                              .codeExchange(authCode, verifier)
                              .then((value) {
                            Navigator.pop(context);
                            setState(() {
                              user = MALManager().getUserInfo();
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
