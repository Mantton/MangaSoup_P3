import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/Providers/SourceProvider.dart';
import 'package:mangasoup_prototype_3/Services/api_manager.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'TagComics.dart';

class AllTagsPage extends StatefulWidget {
  @override
  _AllTagsPageState createState() => _AllTagsPageState();
}

class _AllTagsPageState extends State<AllTagsPage> {
  Future<List<Tag>> _futureComics;

  Future<List<Tag>> _loadComics(String source) async {
    ApiManager _manager = ApiManager();
    return  await _manager.getTags(source);
  }

  @override
  void initState() {
    _futureComics = _loadComics(
        Provider.of<SourceNotifier>(context, listen: false).source.selector);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${Provider.of<SourceNotifier>(context).source.name ?? ""} Tags"),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: _futureComics,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _futureComics = _loadComics(
                          Provider.of<SourceNotifier>(context, listen: false)
                              .source
                              .selector);
                    });
                  },
                  child: Text(
                    "An Error Occurred\n ${snapshot.error}\n Tap to Retry",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              return tagGrid(snapshot.data);
            } else {
              return Center(
                child: Text(
                    "An Error probably occurred, you weren't supposed to see this"),
              );
            }
          }),
    );
  }

  Widget tagGrid(List<Tag> tags) {
    return SingleChildScrollView(
      child: Padding(
        padding:  EdgeInsets.all(10.0),
        child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4.w.toInt(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.7,
            ),
            itemCount: tags.length,
            itemBuilder: (BuildContext context, int index) {
              Tag tag = tags[index];
              return GestureDetector(
                onTap: () {
                  // push to tag page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TagComicsPage(tag: tag,),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(4.0.w),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Text(
                          tag.name, maxLines: 2,
                          softWrap: true,
                          // wrapWords: false,
                          // minFontSize: 5.sp,
                          // maxFontSize: 100.sp,
                          style: TextStyle(
                              color: Colors.white70, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
