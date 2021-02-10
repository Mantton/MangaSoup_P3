import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class WebToonPageAdapter extends StatefulWidget {
  final int initialPage;

  const WebToonPageAdapter({Key key, this.initialPage}) : super(key: key);

  @override
  _WebToonPageAdapterState createState() => _WebToonPageAdapterState();
}

class _WebToonPageAdapterState extends State<WebToonPageAdapter>
   {
  int lastPage = 0;


  ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    print(widget.initialPage);
    itemScrollController = ItemScrollController();
    itemPositionsListener.itemPositions.addListener(() {
      int min = itemPositionsListener.itemPositions.value
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce((ItemPosition min, ItemPosition position) =>
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
          .index;
      int max = itemPositionsListener.itemPositions.value
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce((ItemPosition max, ItemPosition position) =>
              position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
          .index;

      int itemCount = Provider.of<ReaderProvider>(context, listen: false)
          .widgetPageList
          .length;
      if (max != lastPage && max > 0 && max < itemCount) {
        print("MAX: $max ... MIN:$min");
        Provider.of<ReaderProvider>(context, listen: false)
            .pageChanged(max);
        lastPage = max;
      }
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return
       Consumer<ReaderProvider>(builder: (context, provider, _) {
        return ScrollablePositionedList.builder(
          itemBuilder: (_, index) => provider.widgetPageList[index],
          itemCount: provider.widgetPageList.length,
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          initialScrollIndex: widget.initialPage,

        );
      });

  }

}
