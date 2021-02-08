import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Globals.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';

class MultiSelectDialog extends StatefulWidget {
  final List<SettingOption> items;
  final SourceSetting setting;

  const MultiSelectDialog({Key key, this.items, this.setting})
      : super(key: key);

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  List<SettingOption> currentItems = List();

  @override
  void initState() {
    super.initState();
    currentItems = widget.items;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(10),
        height: 660.h,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Multi Select",
                  style: isEmptyFont,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(
              color: Colors.grey[800],
            ),
            Container(
              height: 500.h,
              child: ListView(
                shrinkWrap: true,
                children: widget.setting.options
                    .map((option) => ListTile(
                          title: Text(
                            "${option.name}",
                          ),
                          leading: Icon(
                            currentItems.any((element) =>
                                    element.selector == option.selector)
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                          ),
                          onTap: () {
                            if (currentItems.any((element) =>
                                element.selector == option.selector)) {
                              setState(() {
                                currentItems.removeWhere((element) =>
                                    element.selector == option.selector);
                              });
                            } else {
                              setState(() {
                                currentItems.add(option);
                              });
                            }

                            print(currentItems.map((e) => e.name).toList());
                          },
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            MaterialButton(
              height: 50.h,
              minWidth: 100.w,
              onPressed: () {
                List processedValue =
                    currentItems.map((e) => e.toMap()).toList();
                Navigator.pop(context, processedValue);
              },
              child: Text(
                "Save",
                style: isEmptyFont,
              ),
              color: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
