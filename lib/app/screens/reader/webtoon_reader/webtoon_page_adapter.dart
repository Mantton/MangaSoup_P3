import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:provider/provider.dart';

class WebToonPageAdapter extends StatefulWidget {
  @override
  _WebToonPageAdapterState createState() => _WebToonPageAdapterState();
}

class _WebToonPageAdapterState extends State<WebToonPageAdapter> {
  ScrollController scrollController;
  int lastPage = 0;

  // use this one if the listItem's height is known
  // or width in case of a horizontal list
  void scrollListenerWithItemHeight() {
    int itemHeight = 110; // including padding above and below the list item
    double scrollOffset = scrollController.offset;
    int firstVisibleItemIndex = scrollOffset < itemHeight
        ? 0
        : ((scrollOffset - itemHeight) / itemHeight).ceil();
    print(firstVisibleItemIndex);
  }

  // use this if total item count is known
  void scrollListenerWithItemCount() {
    int itemCount = Provider.of<ReaderProvider>(context, listen: false)
        .widgetPageList
        .length;
    double scrollOffset = scrollController.position.pixels;
    double viewportHeight = scrollController.position.viewportDimension;
    double scrollRange = scrollController.position.maxScrollExtent -
        scrollController.position.minScrollExtent;
    int firstVisibleItemIndex =
        (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();

    if (firstVisibleItemIndex != lastPage &&
        firstVisibleItemIndex > 0 &&
        firstVisibleItemIndex < itemCount) {
      Provider.of<ReaderProvider>(context, listen: false)
          .pageChanged(firstVisibleItemIndex + 1);
      lastPage = firstVisibleItemIndex;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollListenerWithItemCount);
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.removeListener(scrollListenerWithItemCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ReaderProvider>(builder: (context, provider, _) {
          return ListView(
            shrinkWrap: true,
            controller: scrollController,
            children: provider.widgetPageList,
            cacheExtent: MediaQuery
                .of(context)
                .size
                .height * 2,

          );
        }),
      ),
    );
  }
}
