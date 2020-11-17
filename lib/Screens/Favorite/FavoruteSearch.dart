import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/FavoriteGrid.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FavoriteSearch extends StatefulWidget {
  final List<Favorite> favorites;

  const FavoriteSearch({Key key, @required this.favorites}) : super(key: key);

  @override
  _FavoriteSearchState createState() => _FavoriteSearchState();
}

class _FavoriteSearchState extends State<FavoriteSearch> {
  String _query;
  List<Favorite> _results;

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

  Widget body() {
    return Positioned(
      top: 85.h,
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        child: (_results != null)
            ? FavoritesGrid(favorites: _results)
            : Container(
                child: Center(
                  child: Text(
                    "Try Searching!",
                    style: TextStyle(
                      fontSize: 20.sp,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget searchForm() {
    return TextField(
      decoration: msTextField,
      cursorColor: Colors.grey,
      maxLines: 1,
      style: TextStyle(
        height: 1.7,
        color: Colors.grey,
        fontSize: 18,
      ),
      onChanged: (value) async {
        setState(() {
          _query = value;
          _results = searchFavorites(_query);
        });
      },
    );
  }

  List<Favorite> searchFavorites(String query) {
    List<Favorite> re = widget.favorites
        .where(
          (element) => element.highlight.title.toLowerCase().startsWith(
                query.toLowerCase(),
              ),
        )
        .toList();
    return re;
  }
}
