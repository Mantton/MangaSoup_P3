import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/database_provider.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/screens/migrate/migrate_select_source.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

class MigrationHome extends StatefulWidget {
  @override
  _MigrationHomeState createState() => _MigrationHomeState();
}

class _MigrationHomeState extends State<MigrationHome> {
  List<Comic> _comics = List();

  @override
  void initState() {
    _comics = List.of(Provider.of<DatabaseProvider>(context, listen: false)
        .comics
        .where((element) => element.inLibrary));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Migrate"),
        centerTitle: true,
      ),
      body: Consumer<DatabaseProvider>(builder: (context, provider, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  children: [
                    Text(
                      "Select Comic to Migrate",
                      style: notInLibraryFont,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      decoration: mangasoupInputDecoration("Search Library"),
                      onChanged: (query) {
                        setState(() {
                          _comics = Provider.of<DatabaseProvider>(context,
                                  listen: false)
                              .searchLibrary(query);
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: SelectComic(
                provider: provider,
                comics: _comics,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class SelectComic extends StatelessWidget {
  final DatabaseProvider provider;
  final List<Comic> comics;

  const SelectComic({Key key, this.provider, this.comics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comics.isNotEmpty)
      return ListView.builder(
        itemCount: comics.length,
        shrinkWrap: true,
        itemBuilder: (_, index) => ListTile(
          selectedTileColor: Colors.grey[900],
          title: Text(comics[index].title),
          subtitle: Text(comics[index].source),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MigrateSourceSelector(
                comic: comics[index],
              ),
            ),
          ),
        ),
      );
    else
      return Center(
        child: Text(
          "No Comics Found",
          style: notInLibraryFont,
        ),
      );
  }
}

/*
* FLOW
* select comic
* select destination source
* confirm selection result
* sync comic to library to replace former & sync read chapters
* return to migration home
*
* */
