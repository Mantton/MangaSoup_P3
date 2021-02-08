import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Screens/WebViews/mangadex_login.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/mangadex/models/mangadex_profile.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:mangasoup_prototype_3/app/screens/mangadex/mangadex_user_libary.dart';
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
              return Center(
                child: Text("An Unknown Error Occurred\n${snapshot.error}"),
              );
            else if (snapshot.hasData)
              return Container(
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[900],
                      margin: EdgeInsets.all(10.w),
                      child: Row(
                        children: [
                          Container(
                            width: 140.w,
                            height: 150.h,
                            padding: EdgeInsets.all(5.w),
                            child: SoupImage(
                              url: snapshot.data.avatar,
                              referer: "mangadex.org",
                            ),
                          ),
                          Text(
                            snapshot.data.username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40.sp,
                              fontFamily: "lato",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: ListTile(
                        title: Text(
                          "View Follow Library",
                          style: notInLibraryFont,
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.purple,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MangaDexUserLibrary(),
                          ),
                        ),
                      ),
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
                          (value){
                            setState(() {
                              profile = get();
                            });
                          }
                          ,
                        ),
                      ),
                    ],
                  ),
                ),
              );
          },
        ));
  }
}
