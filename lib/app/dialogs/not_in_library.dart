import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

notInLibraryDialog({@required BuildContext context, int comicId}) {
  showGeneralDialog(
    barrierLabel: "Not In Library",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => buildNotInLibraryDialog(context, comicId),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

createCollectionDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Create Collection",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => createCollectionBuilder(context),
    transitionBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
        child: child,
      );
    },
  );
}

createCollectionBuilder(BuildContext context) => Dialog(
      backgroundColor: Colors.grey[900], //blue for testing, change to black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: CreateCollectionWidget(),
    );
buildNotInLibraryDialog(BuildContext context, int comicId) => Dialog(
      backgroundColor: Colors.grey[900], //blue for testing, change to black
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: AddToLibrary(comicId: comicId),
    );

class AddToLibrary extends StatefulWidget {
  final int comicId;

  const AddToLibrary({Key key, this.comicId}) : super(key: key);
  @override
  _AddToLibraryState createState() => _AddToLibraryState();
}

class _AddToLibraryState extends State<AddToLibrary> {
  List<Collection> _selectedCollections = List();
  int initialCount = 0;

  toggleSelection(Collection collection) {
    if (_selectedCollections.contains(collection)) {
      _selectedCollections.remove(collection);
    } else
      _selectedCollections.add(collection);
    setState(() {});
  }

  @override
  void initState() {
    List<int> confirmed = Provider.of<DatabaseProvider>(context, listen: false)
        .getSpecificComicCollectionIds(widget.comicId);
    _selectedCollections.addAll(
        Provider.of<DatabaseProvider>(context, listen: false)
            .collections
            .where((element) => confirmed.contains(element.id)));
    initialCount = _selectedCollections.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      if (provider.collections.length > 1) {
        List<Collection> collections = List.of(provider.collections);
        collections.removeWhere(
            (element) => element.order == 0); // Remove default collection
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Padding(
                padding: EdgeInsets.all(10.0.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add to Library",
                      style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Widget>.generate(
                          collections.length,
                          (index) => ListTile(
                            selected: _selectedCollections
                                .contains(collections[index]),
                            selectedTileColor: Colors.grey[800],
                            leading: Icon(
                              _selectedCollections.contains(collections[index])
                                  ? Icons.check_box_outlined
                                  : Icons.check_box_outline_blank,
                              color: Colors.white,
                            ),
                            title: Text(
                              collections[index].name,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            onTap: () {
                              toggleSelection(collections[index]);
                            },
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Create New Collection",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.lightBlueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        createCollectionDialog(context: context);
                      },
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 15.w),
                      child: Row(
                        children: [
                          FlatButton(
                            child: Text(
                              "Cancel",
                              style: createCancelStyle,
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Spacer(),
                          FlatButton(
                            disabledColor: Colors.grey[900],
                            child: Text(
                              (_selectedCollections.isNotEmpty)
                                  ? "Confirm"
                                  : (initialCount > 0)
                                      ? "Remove from Library"
                                      : "",
                              style: createCancelStyle,
                              textAlign: TextAlign.center,
                            ),
                            onPressed: (_selectedCollections.isNotEmpty)
                                ? () async {
                                    Navigator.pop(context);
                                    showLoadingDialog(context);
                                    await provider.addToLibrary(
                                        _selectedCollections, widget.comicId);
                                    Navigator.pop(context);
                                  }
                                : (initialCount > 0)
                                    ? () async {
                                        Navigator.pop(context);
                                        showLoadingDialog(context);
                                        await provider.addToLibrary(
                                            _selectedCollections,
                                            widget.comicId,
                                            remove: true);
                                        Navigator.pop(context);
                                      }
                                    : null,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      } else
        return CreateCollectionWidget();
    });
  }
}

class CreateCollectionWidget extends StatefulWidget {
  @override
  _CreateCollectionWidgetState createState() => _CreateCollectionWidgetState();
}

class _CreateCollectionWidgetState extends State<CreateCollectionWidget> {
  final _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<String> create() async {
    if (_formKey.currentState.validate()) {
      // If Valid
      print(_textController.text);
      Collection collection =
          await Provider.of<DatabaseProvider>(context, listen: false)
              .createCollection(_textController.text);
      Navigator.pop(context);
      return collection.name;
    } else
      return null;
  }

  String consumerValidator(String value) {
    bool alreadyExists = Provider.of<DatabaseProvider>(context, listen: false)
        .checkIfCollectionExists(value);

    if (alreadyExists) return "A collection already exists with this name.";
    if (value.isEmpty) return "Collection name cannot be empty.";
    if (value.toLowerCase() == "default")
      return "Cannot override 'Default' collection.";
    if (value.length >= 20) return "Collection name too long.";
    if (value.length <= 2) return "Collection name too short.";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(10.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create Collection",
                  style: TextStyle(
                    fontFamily: "roboto",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _textController,
                        decoration: createCollectionFormDecoration,
                        cursorColor: Colors.grey,
                        maxLines: 1,
                        style: textFieldStyle,
                        validator: consumerValidator,
                        autofocus: true,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            child: Text(
                              "Cancel",
                              style: createCancelStyle,
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          InkWell(
                            child: Text(
                              "Create",
                              style: createCancelStyle,
                            ),
                            onTap: () async {
                              showLoadingDialog(context);
                              String name = await create();
                              if (name != null) {
                                Navigator.pop(context);
                                showMessage(
                                  "Created $name",
                                  Icons.check,
                                  Duration(seconds: 1),
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
