import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Components/Images.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Models/Source.dart';
import 'package:mangasoup_prototype_3/Screens/Browse/multi_source_search/muli_source_results.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

class MultiSourceSearch extends StatefulWidget {
  @override
  _MultiSourceSearchState createState() => _MultiSourceSearchState();
}

class _MultiSourceSearchState extends State<MultiSourceSearch> {
  List<Source> sources = [];
  List<Source> _selectedSources = [];
  Future<List<Source>> fut;

  Future<List<Source>> getSources() async {
    List<Source> _sources = await ApiManager().getServerSources(
        Provider.of<PreferenceProvider>(context, listen: false)
            .languageServer); // Retrieve Source
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
        title: Text(
          "Select Sources (${Provider.of<PreferenceProvider>(context).languageServer})",
        ),
        centerTitle: true,
        actions: [
          _selectedSources.isNotEmpty
              ? InkWell(
                  onTap: () => _selectedSources.length <= 7
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MultiSearchResult(sources: _selectedSources),
                          ),
                        )
                      : showSnackBarMessage("Too many Selections!",
                          error: true),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        "Proceed",
                        style: TextStyle(
                          color: Colors.blue,
                          fontFamily: "Lato",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
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
                  return buildPrepareSourcesWidget(snapshot);
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

  Padding buildPrepareSourcesWidget(AsyncSnapshot snapshot) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 5,
          ),
          TextField(
            decoration: mangasoupInputDecoration("Search Sources"),
            onChanged: (v) => searchComics(v, snapshot.data),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: GridView.builder(
              itemCount: sources.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3.w.toInt(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .77, // 77/100
              ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  onTap: () => toggleSelection(sources[index]),
                  child: Container(
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  toggleSelection(Source source) {
    if (source.isEnabled) {
      // toggle logic
      if (_selectedSources.contains(source))
        _selectedSources.remove(source);
      else
        _selectedSources.add(source);
      setState(() {});
    } // else do nothing
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
    return (!sources[index].isEnabled)
        ? Colors.red
        : _selectedSources.contains(sources[index])
            ? Colors.green
            : Colors.grey[900];
  }
}
