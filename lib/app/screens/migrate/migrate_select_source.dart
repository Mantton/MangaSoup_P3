import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/database/models/comic.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';

class MigrateSourceSelector extends StatefulWidget {
  final Comic comic;

  const MigrateSourceSelector({Key key, this.comic}) : super(key: key);

  @override
  _MigrateSourceSelectorState createState() => _MigrateSourceSelectorState();
}

class _MigrateSourceSelectorState extends State<MigrateSourceSelector> {
  List<Source> sources = List();
  List<Source> _selectedSources = List();
  Future<List<Source>> fut;

  Future<List<Source>> getSources() async {
    List<Source> _sources =
        await ApiManager().getServerSources("live"); // Retrieve Source
    sources = _sources;
    return sources;
  }

  @override
  void initState() {
    fut = getSources();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Sources"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Builder(
          builder: (_) {
            return FutureBuilder(
              future: fut,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: LoadingIndicator(),
                  );
                else if (snapshot.hasError)
                  return Center(
                    child: Text(
                      "Unable to Fetch Source List",
                      style: notInLibraryFont,
                    ),
                  );
                else if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "Select Possible Destination Sources",
                          style: notInLibraryFont,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextField(
                          decoration:
                              mangasoupInputDecoration("Search Sources"),
                          onChanged: (v) => searchComics(v, snapshot.data),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: GridView.builder(
                            itemCount: sources.length,
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3.w.toInt(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: .77, // 77/100
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: getColor(
                                      index,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridTile(
                                    child: SoupImage(
                                      url: sources[index].thumbnail,
                                      fit: BoxFit.scaleDown,
                                    ),
                                    footer: Center(
                                      child: FittedBox(
                                        child: Text(
                                          sources[index].name,
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else
                  return Center(
                    child: Text(
                      "Critical Error\n"
                      "You are not supposed to be seeing this."
                      "\nContact Dev.",
                    ),
                  );
              },
            );
          },
        ),
      ),
    );
  }

  searchComics(String query, List<Source> snapshot) {
    setState(() {
      sources = snapshot
          .where(
            (element) => element.name.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  Color getColor(int index) {
    return (!sources[index].isEnabled ||
            widget.comic.sourceSelector == sources[index].selector)
        ? Colors.red
        : Colors.grey[900];
  }
}
