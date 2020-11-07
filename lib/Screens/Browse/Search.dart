import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/HighlightGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Comic.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Screens/MangaDex/DexLogin.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/Utilities/Exceptions.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';
  ApiManager _manager = ApiManager();
  Future<List<ComicHighlight>> _futureComics;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            header(),
            body(),
          ],
        ),
      ),
    );
  }

  Widget header() {
    return Positioned(
      top: 10.h,
      left: 0,
      right: 0,
      child: Container(
        height: 70.h,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              color: Colors.purple,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: searchForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchForm() {
    return TextField(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[800]),
          gapPadding: 5,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey[600]),
          gapPadding: 5,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red),
          gapPadding: 5,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.redAccent),
          gapPadding: 5,
        ),
        suffixIcon: Icon(
          Icons.search,
          color: Colors.purple,
        ),
      ),
      cursorColor: Colors.grey,
      maxLines: 1,
      style: TextStyle(
        height: 1.7,
        color: Colors.grey,
        fontSize: 18,
      ),
      onSubmitted: (value) async {
        setState(() {
          _query = value;
        });

        _futureComics = _manager.search(
            Provider.of<SourceNotifier>(context, listen: false).source.selector,
            _query);
      },
    );
  }

  Widget body() {
    return Positioned(
      top: 85.h,
      left: 0,
      right: 0,
      bottom: 0,
      child: searchBody(),
    );
  }

  Widget searchBody() {
    return Padding(
      padding: EdgeInsets.all(8.0.w),
      child: FutureBuilder(
          future: _futureComics,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              if (snapshot.error == MissingMangaDexSession) {
                return CupertinoButton(
                    child: Text(
                      "You are not Logged in to MangaDex\n Tap to login",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => MangadexLoginPage(),
                            fullscreenDialog: true,),
                      );

                      showSnackBarMessage(result);
                      setState(() {
                        _futureComics = _manager.search(
                            Provider.of<SourceNotifier>(context, listen: false)
                                .source
                                .selector,
                            _query);
                      });
                    });
              } else {
                return InkWell(
                  child: Text(
                    "An Error Occurred \n ${snapshot.error} \n Tap to retry",
                    textAlign: TextAlign.center,
                  ),
                );
              }
            }
            if (snapshot.hasData) {
              return Container(
                // color: Colors.redAccent,
                child: ComicGrid(
                  comics: snapshot.data,
                ),
              );
            } else {
              return Container(
                height: 300.h,
                margin: EdgeInsets.only(top: 10.h),
                child: Center(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "Searching from ${Provider.of<SourceNotifier>(context).source.name}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      CupertinoButton(
                        child: Text(
                          "Image Search",
                          style: TextStyle(fontSize: 23),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
