import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/reader/reader_provider.dart';
import 'package:provider/provider.dart';

preferenceDialog({@required BuildContext context}) {
  showGeneralDialog(
    barrierLabel: "Rate This Comic",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: Duration(milliseconds: 70),
    context: context,
    pageBuilder: (_, __, ___) => preferenceBuilder(context),
  );
}

preferenceBuilder(BuildContext context) => Dialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        margin: EdgeInsets.all(10.w),
        padding: EdgeInsets.all(7.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 22,
              ),
            ),
            Divider(
              thickness: 3,
              color: Colors.grey[900],
              indent: 10,
              endIndent: 10,
            ),
            // Reading Mode
            /// Options
            ///
            readerModeSetting(),
            Consumer<PreferenceProvider>(
              builder: (BuildContext context, provider, _) =>
                  provider.readerMode == 1 ? mangaModeOptions() : Container(),
            ),

            SizedBox(
              height: 8,
            ),
            MaterialButton(
              height: 50,
              minWidth: 100.w,
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: notInLibraryFont,
              ),
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );

Widget readerModeSetting() {
  return Row(
    children: [
      Text(
        "Reader Mode",
        style: TextStyle(
          color: Colors.grey,
          fontSize: 20,
        ),
      ),
      SizedBox(
        width: 10,
      ),
      Spacer(),
      Consumer<PreferenceProvider>(builder: (context, provider, _) {
        return Container(
          padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey[900],
            border: Border.all(),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              items: provider.buildItems(provider.readerModeOptions),
              dropdownColor: Colors.grey[900],
              value: provider.readerMode,
              onChanged: (value) {
                Provider.of<ReaderProvider>(context, listen: false).changeMode();
                provider.setReaderMode(value);
              },
            ),
          ),
        );
      })
    ],
  );
}

Widget mangaModeOptions() {
  return Container(
    margin: EdgeInsets.only(top: 15),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Manga Mode Settings",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 19,
          ),
        ),
        Divider(
          thickness: 3,
          color: Colors.grey[900],
          indent: 10,
          endIndent: 10,
        ),

        /// Orientation
        Row(
          children: [
            Text(
              "Orientation",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            SizedBox(
              width: 25,
            ),
            Spacer(),
            Consumer<PreferenceProvider>(builder: (context, provider, _) {
              return Container(
                padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[900],
                    border: Border.all()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    items:
                        provider.buildItems(provider.readerOrientationOptions),
                    dropdownColor: Colors.grey[900],
                    value: provider.readerOrientation,
                    onChanged: (value) {
                      provider.setReaderOrientation(value);
                    },
                  ),
                ),
              );
            })
          ],
        ),
        SizedBox(
          height: 5,
        ),

        /// Scroll Direction
        Column(
          children: [
            Row(
              children: [
                Text(
                  "Scroll Direction",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                Spacer(),
                Consumer<PreferenceProvider>(builder: (context, provider, _) {
                  return Container(
                    padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[900],
                      border: Border.all(),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        items: provider.buildItems(provider.readerOrientation ==
                                1
                            ? provider.readerScrollDirectionOptionsHorizontal
                            : provider.readerScrollDirectionOptionsVertical),
                        dropdownColor: Colors.grey[900],
                        value: provider.readerScrollDirection,
                        onChanged: (value) {
                          provider.setReaderScrollDirection(value);
                        },
                      ),
                    ),
                  );
                })
              ],
            ),
          ],
        ),

        SizedBox(
          height: 5,
        ),

        /// Page Snapping
        Column(
          children: [
            Row(
              children: [
                Text(
                  "Page Padding",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                Spacer(),
                Consumer<PreferenceProvider>(builder: (context, provider, _) {
                  return Container(
                    padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                    child: PlatformSwitch(
                      value: provider.readerPadding,
                      onChanged: (v) =>
                          provider.setReaderPadding(!provider.readerPadding),
                    ),
                  );
                })
              ],
            ),
          ],
        ),

        /// Page Snapping
        Column(
          children: [
            Row(
              children: [
                Text(
                  "Page Snapping",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                Spacer(),
                Consumer<PreferenceProvider>(builder: (context, provider, _) {
                  return Container(
                    padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
                    child: PlatformSwitch(
                      value: provider.readerPageSnapping,
                      onChanged: (v) => provider
                          .setReaderPageSnapping(!provider.readerPageSnapping),
                    ),
                  );
                })
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
