import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/enums/mal.dart';

score() {}

statusPicker() {}

chapterPicker() {}

datePickerDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Date Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => datePickerBuilder(),
  );
}

datePickerBuilder() {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: MangaSoupDatePicker(),
  );
}

class MangaSoupDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Date Picker",
            style: notInLibraryFont,
          ),
          Container(
            height: 200,
            child: PlatformWidget(
              cupertino: (_, __) =>
                  CupertinoDatePicker(onDateTimeChanged: (v) => null),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Spacer(),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Set",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

scorePickerDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Date Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => scorePickerBuilder(),
  );
}

scorePickerBuilder() {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: MangaSoupScorePicker(),
  );
}

class MangaSoupScorePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Score Picker",
            style: notInLibraryFont,
          ),
          Container(
            height: 150,
            child: PlatformWidget(
              cupertino: (_, __) => CupertinoPicker.builder(
                itemExtent: 40,
                onSelectedItemChanged: (i) => print("$i"),
                childCount: 10,
                itemBuilder: (_, index) => Center(
                  child: Text("${index + 1}"),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: InkWell(
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Spacer(),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: InkWell(
                  child: Text(
                    "Set",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blue,
                      fontFamily: "Lato",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

statusPickerDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Date Picker Dialog",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => statusPickerBuilder(),
  );
}

statusPickerBuilder() {
  return Dialog(
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: Container(
      child: MangaSoupMalStatusPicker(),
      height: 450,
    ),
  );
}

class MangaSoupMalStatusPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Text(
              "Status Picker",
              style: notInLibraryFont,
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: MALTrackStatus.values.length,
                itemBuilder: (_, index) => CheckboxListTile(
                  title: Text(
                    convertToPresentatble(
                      MALTrackStatus.values[index],
                    ),
                  ),
                  onChanged: (bool value) {},
                  value: true,
                  checkColor: Colors.purple,
                  activeColor: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: InkWell(
                    child: Text(
                      "Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: "Lato",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    child: Text(
                      "Set",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue,
                        fontFamily: "Lato",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
