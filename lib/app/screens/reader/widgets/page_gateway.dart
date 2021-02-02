import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/models/reader_page.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/paged_reader/paged_view_holder.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/widgets/reader_transition_page.dart';

class PageGateWay extends StatefulWidget {
  // ReaderPage Stuff
  final ReaderPage page;

  // Transition Stuff
  final bool isTransition;
  final Chapter current;
  final Chapter next;

  const PageGateWay(
      {Key key, this.isTransition, this.current, this.next, this.page})
      : super(key: key);
  @override
  _PageGateWayState createState() => _PageGateWayState();
}

class _PageGateWayState extends State<PageGateWay> {
  @override
  Widget build(BuildContext context) {
    if (widget.isTransition) {
      return TransitionPage(
        current: widget.current,
        next: widget.next,
      );
    } else {
      return PagedViewHolder(
        page: widget.page,
      );
    }
  }
}
