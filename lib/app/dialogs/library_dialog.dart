import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/collection.dart';
import 'package:provider/provider.dart';

libraryDialog({@required BuildContext context, int comicId}) {
  buildCollectionSheet(context, comicId);

  // showGeneralDialog(
  //   barrierLabel: "Not In Library",
  //   barrierDismissible: true,
  //   barrierColor: Colors.black.withOpacity(0.5),
  //   transitionDuration: Duration(milliseconds: 70),
  //   context: context,
  //   pageBuilder: (_, __, ___) => buildLibraryDialog(context, comicId),
  //   transitionBuilder: (_, anim, __, child) {
  //     return SlideTransition(
  //       position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim),
  //       child: child,
  //     );
  //   },
  // );
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
      child: Container(),
    );

buildLibraryDialog(BuildContext context, int comicId) => Dialog(
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

  toggleSelection(Collection collection) async {
    if (_selectedCollections.contains(collection)) {
      _selectedCollections.remove(collection);
    } else
      _selectedCollections.add(collection);
    setState(() {});

    // DataBase / Provider Logic
    if (_selectedCollections.isNotEmpty) {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .addToLibrary(_selectedCollections, widget.comicId);
    } else if (initialCount > 0) {
      await Provider.of<DatabaseProvider>(context, listen: false)
          .addToLibrary(_selectedCollections, widget.comicId, remove: true);
    }
  }

  @override
  void initState() {
    List<int> confirmed = Provider.of<DatabaseProvider>(context, listen: false)
        .getSpecificComicCollectionIds(widget.comicId);
    _selectedCollections.addAll(
      Provider.of<DatabaseProvider>(context, listen: false).collections.where(
            (element) => confirmed.contains(element.id),
          ),
    );
    initialCount = _selectedCollections.length;
    super.initState();
  }

  Widget listView(List<Collection> collections) => ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, index) => ListTile(
          tileColor: Color.fromRGBO(9, 9, 9, 1.0),
          title: Text(
            collections[index].name,
            style: TextStyle(
              fontFamily: "Lato",
              fontSize: 17,
            ),
          ),
          trailing: _selectedCollections.contains(collections[index])
              ? Icon(
                  Icons.check,
                  color: Colors.purpleAccent,
                )
              : null,
          onTap: () {
            toggleSelection(collections[index]);
          },
        ),
        separatorBuilder: (_, index) => SizedBox(
          height: 2,
        ),
        itemCount: collections.length,
      );

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
        builder: (BuildContext context, provider, _) {
      List<Collection> collections = List.of(provider.collections);
      if (!provider.comicCollections
          .any((e) => e.collectionId == 1 && e.comicId == widget.comicId)) {
        // Remove default collection
        collections.removeWhere((element) => element.order == 0);
      }
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            // physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 3),
                listView(collections),
                SizedBox(
                  height: 5,
                ),
                collections.length <= 5 ? AddCollection() : Container(),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class AddCollection extends StatefulWidget {
  final bool rename;
  final int collectionID;
  final bool dialog;

  const AddCollection(
      {Key key, this.rename = false, this.collectionID, this.dialog = false})
      : super(key: key);

  @override
  _AddCollectionState createState() => _AddCollectionState();
}

class _AddCollectionState extends State<AddCollection> {
  final _textController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String consumerValidator(String value) {
    bool alreadyExists = Provider.of<DatabaseProvider>(context, listen: false)
        .checkIfCollectionExists(value);

    if (alreadyExists) return "A collection already exists with this name.";
    if (value.isEmpty) return "Collection name cannot be empty.";
    if (value.toLowerCase() == "default")
      return "Cannot override 'Default' collection.";
    if (value.length >= 20) return "Collection name too long.";
    return null;
  }

  Future<void> create() async {
    if (_formKey.currentState.validate()) {
      // If Valid
      if (widget.rename) if (widget.collectionID == null)
        showSnackBarMessage("Bad Implementation Contact Dev Team", error: true);
      else {
        Collection c = Provider.of<DatabaseProvider>(context, listen: false)
            .collections
            .firstWhere((element) => element.id == widget.collectionID);
        c.name = _textController.text.trim();
        await Provider.of<DatabaseProvider>(context, listen: false)
            .updateCollection(c);
        Navigator.pop(context);
      }
      else {
        await Provider.of<DatabaseProvider>(context, listen: false)
            .createCollection(_textController.text.trim());

        if (widget.dialog) Navigator.pop(context);
      }

      setState(() {
        _textController.clear();
      });
    } else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(10, 10, 10, 1.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: _formKey,
            child: CupertinoTextFormFieldRow(
              controller: _textController,
              placeholder: "Collection Name",
              cursorColor: Colors.grey,
              maxLines: 1,
              style: textFieldStyle,
              validator: consumerValidator,
              autofocus: false,
            ),
          ),
          Divider(),
          CupertinoButton(
            onPressed: () => create(),
            child: Text(widget.rename ? "Rename" : "Create Collection"),
          ),
        ],
      ),
    );
  }
}

buildCollectionSheet(BuildContext context, int id) {
  showModalBottomSheet(
    isScrollControlled: true,
    enableDrag: false,
    context: context,
    // elevation: 10,
    builder: (_) => Container(
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? MediaQuery.of(context).size.height * .85
          : MediaQuery.of(context).size.height,
      child: CupertinoPageScaffold(
        // resizeToAvoidBottomInset: true,
        navigationBar: CupertinoNavigationBar(
          middle: Text('Collections'),
          leading: Container(),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: Colors.black,
        child: SafeArea(
          child: AddToLibrary(
            comicId: id,
          ),
        ),
      ),
    ),
  );
}
