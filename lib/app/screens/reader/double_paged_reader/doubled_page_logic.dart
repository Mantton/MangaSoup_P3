import 'package:flutter/material.dart';

Map<String, dynamic> createDouble(List<Widget> widgets, bool x) {
  List<Widget> output = List();
  List pagePointers = List();
  for (int index = 0; index < widgets.length; index++) {
    Widget next;
    try {
      next = widgets[index + 1];
    } catch (err) {}
    Widget row;
    if (next != null) {
      row = Row(
        children: [
          x ? Expanded(child: next) : Expanded(child: widgets[index]),
          x ? Expanded(child: widgets[index]) : Expanded(child: next),
        ],
      );
      pagePointers.add(index + 2);
    } else {
      try {
        row = widgets[index];
      } catch (err) {
        row = widgets[index - 1];
      }
      pagePointers.add(index + 1);
    }
    output.add(row);
    index += 1;
  }
  return {"widgets": output, "pages": pagePointers};
}

int doublePagedGetInitial(int initial) {
  if (initial == 0)
    return 0;
  else {
    int t = ((initial / 2) - 1).round();
    return t;
  }
}
