import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/FavoriteGrid.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Database/FavoritesDatabase.dart';
import 'package:mangasoup_prototype_3/Models/Favorite.dart';
import 'package:mangasoup_prototype_3/Providers/FavoriteProvider.dart';
import 'package:provider/provider.dart';

class FavoriteCollectionEdit extends StatefulWidget {
  final List<Favorite> favorites;
  final List collections;
  final String currentCollectionName;

  const FavoriteCollectionEdit(
      {Key key,
      @required this.favorites,
      @required this.collections,
      @required this.currentCollectionName})
      : super(key: key);

  @override
  _FavoriteCollectionEditState createState() => _FavoriteCollectionEditState();
}

class _FavoriteCollectionEditState extends State<FavoriteCollectionEdit> {
  List<Favorite> _favs;
  List<Favorite> _selectedItems = List();
  List _collections;
  String _collectionName;
  FavoritesManager _manager = FavoritesManager();

  /// Font
  final collectionFont =
      TextStyle(color: Colors.white, fontSize: 17.h, fontFamily: "Roboto");

  final headerFont =
      TextStyle(color: Colors.white, fontSize: 20.h, fontFamily: "Roboto");

  @override
  void initState() {
    _favs = widget.favorites;
    _collectionName = widget.currentCollectionName;
    _collections = widget.collections;
    _collections.remove(_collectionName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$_collectionName Edit"),
        actions: [
          (_favs.length != 0)
              ? Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Center(
                    child: InkWell(
                      child: Text(
                        "Rename \n Collection",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        await rename();
                      },
                    ),
                  ),
                )
              : Container(),
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            child: GridView.builder(
              itemCount: _favs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: .75,
                crossAxisSpacing: 5.w,
                mainAxisSpacing: 10.w,
              ),
              itemBuilder: (BuildContext context, int index) => InkWell(
                onTap: () {
                  setState(() {
                    (!_selectedItems.contains(_favs[index]))
                        ? _selectedItems.add(_favs[index])
                        : _selectedItems.remove(_favs[index]);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(
                    10.w,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (_selectedItems.contains(_favs[index]))
                          ? Colors.grey
                          : Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: IgnorePointer(
                    child: FavoritesTile(
                      favorite: _favs[index],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// BREak
          AnimatedPositioned(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
            bottom: (_selectedItems.length == 0) ? -207.h : 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              height: 207.h,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: EdgeInsets.all(8.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${_selectedItems.length} Selected",
                      style: headerFont,
                    ),
                    ListTile(
                      title: Text(
                        "Move to different collection",
                        style: collectionFont,
                      ),
                      trailing: Icon(
                        CupertinoIcons.folder_open,
                        color: Colors.purple,
                      ),
                      onTap: () async {
                        await move();
                      },
                    ),
                    Divider(
                      color: Colors.grey[800],
                      thickness: 2.w,
                      height: 0,
                    ),
                    ListTile(
                      title: Text(
                        "Delete from collection",
                        style: collectionFont,
                      ),
                      trailing: Icon(
                        CupertinoIcons.delete,
                        color: Colors.purple,
                      ),
                      onTap: () async {
                        showLoadingDialog(context);
                        // Provider Delete
                        await Provider.of<FavoriteProvider>(context, listen:false).deleteBulk(_selectedItems);

                        // Edit View Delete
                        _favs.removeWhere(
                              (element) => _selectedItems.contains(element),
                        );
                        _selectedItems.clear();
                        setState(() {});
                        Navigator.pop(context);
                        showMessage(
                          "Done!",
                          CupertinoIcons.check_mark,
                          Duration(seconds: 1),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.grey[800],
                      thickness: 2,
                      height: 0,
                    ),
                    ListTile(
                      title: Text(
                        "Cancel",
                        style: collectionFont,
                      ),
                      onTap: () {
                        setState(() {
                          _selectedItems.clear();
                        });
                      },
                      trailing: Icon(
                        CupertinoIcons.clear,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  move() {
    return showPlatformModalSheet(
      context: context,
      builder: (_) => PlatformWidget(
        material: (_, __) => Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: List<Widget>.generate(
                  _collections.length,
                  (index) => ListTile(
                    title: Text(
                      _collections[index],
                      style: collectionFont,
                    ),
                    onTap: () async {
                      await moveCollection(_collections[index]);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  "Create New Collection",
                  style: collectionFont,
                ),
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
                    widget.collections.length,
                    (index) => CupertinoActionSheetAction(
                      onPressed: () async {
                        await moveCollection(_collections[index]);
                      },
                      child: Text(
                        widget.collections[index],
                      ),
                    ),
                  ),
                ),
                CupertinoActionSheetAction(
                  onPressed: () async {
                    Navigator.pop(context);
                    await createCollection();
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

  moveCollection(String name) async {
    showLoadingDialog(context);
    await Provider.of<FavoriteProvider>(context, listen: false).moveCollection(
      toChange: _selectedItems,
      oldCollectionName: _selectedItems[0].collection,
      newCollectionName: name,
      collectionLength: _favs.length
    );

    // Edit View Delete
    _favs.removeWhere(
          (element) => _selectedItems.contains(element),
    );
    _selectedItems.clear();
    setState(() {});
    Navigator.pop(context);
    Navigator.pop(context);
    showMessage(
      "Done!",
      CupertinoIcons.check_mark,
      Duration(seconds: 1),
    );
  }

  createCollection() {
    String newCollectionName = "";
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
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
                  Navigator.pop(context);
                  await moveCollection(newCollectionName);
                }
              }
            },
          )
        ],
      ),
    );
  }

  rename() {
    String newCollectionName = "";
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text("Rename Collection"),
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
                  Navigator.pop(context);

                  //rename
                  showLoadingDialog(context);
                  await Provider.of<FavoriteProvider>(context, listen: false).moveCollection(
                      toChange: _favs,
                      oldCollectionName: _collectionName,
                      newCollectionName: newCollectionName,
                      collectionLength: _favs.length,
                    rename: true
                  );

                  print(_collectionName);
                  setState(() {
                    _collectionName = newCollectionName;

                  });
                  Navigator.pop(context);
                  showMessage(
                    "Done!",
                    CupertinoIcons.check_mark,
                    Duration(seconds: 1),
                  );
                }
              }
            },
          )
        ],
      ),
    );
  }
}
