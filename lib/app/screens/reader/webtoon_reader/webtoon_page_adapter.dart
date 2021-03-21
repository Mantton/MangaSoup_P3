import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/physics.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WebToonPageAdapter extends StatefulWidget {
  final ItemScrollController controller;

  const WebToonPageAdapter({Key key, this.controller}) : super(key: key);

  @override
  _WebToonPageAdapterState createState() => _WebToonPageAdapterState();
}

class _WebToonPageAdapterState extends State<WebToonPageAdapter> {
  int lastPage = -1;

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    itemPositionsListener.itemPositions.addListener(() {
      var item = itemPositionsListener.itemPositions.value
          .where((ItemPosition position) => position.itemLeadingEdge < .33)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max);

      var last = itemPositionsListener.itemPositions.value
          .where((ItemPosition position) => position.itemLeadingEdge < .9)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max);
      int max = item.index;
      int t = last.index;
      int itemCount = Provider.of<ReaderProvider>(context, listen: false)
          .widgetPageList
          .length;
      // print("$max, $t, $itemCount");
      if (t + 1 == itemCount) {
        max = t;
      }
      if (max != lastPage && max >= 0 && max < itemCount) {
        // Check if scroll controller is on the last page
        Provider.of<ReaderProvider>(context, listen: false).pageChanged(max);
        lastPage = max;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReaderProvider>(builder: (context, provider, _) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ScrollablePositionedList.builder(
          addAutomaticKeepAlives: false,
          physics: NewCustomScrollPhysics(
            velocityT:
                Provider.of<PreferenceProvider>(context).maxScrollVelocity,
          ),
          itemBuilder: (_, index) => provider.widgetPageList.isNotEmpty
              ? provider.widgetPageList[index]
              : SizedBox(
                  height: 50,
                ),
          itemCount: provider.widgetPageList.length,
          itemScrollController: widget.controller,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: provider.initialPageIndex,
        ),
      );
    });
  }
}
