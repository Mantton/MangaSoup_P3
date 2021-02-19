import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mangasoup_prototype_3/Models/Setting.dart';
import 'package:mangasoup_prototype_3/Providers/BrowseProvider.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/widgets/textfields.dart';
import 'package:provider/provider.dart';

class TesterFilter extends StatelessWidget {
  final SourceSetting filter;

  const TesterFilter({Key key, @required this.filter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 5),
      child: Column(
        children: [
          filterGroups(context),
        ],
      ),
    );
  }

  List<DropdownMenuItem<SettingOption>> buildDropDownMenuItems(
      List<SettingOption> options) {
    List<DropdownMenuItem<SettingOption>> items = List();
    for (SettingOption opt in options) {
      items.add(
        DropdownMenuItem<SettingOption>(
          child: Text(opt.name),
          value: opt,
        ),
      );
    }
    return items;
  }

  Widget filterGroups(BuildContext context) {
    switch (filter.type) {
      case 1:
        return TextField(
          decoration: mangasoupInputDecoration(filter.name),
          cursorColor: Colors.purple,
          onChanged: (value) =>
              Provider.of<BrowseProvider>(context, listen: false)
                  .save(filter.selector, filter.type, "$value"),
        );

      case 2:
        int x = filter.options.indexWhere((element) =>
            Provider.of<BrowseProvider>(context)
                .data['${filter.selector}']
                .selector ==
            element.selector);
        return Row(
          children: [
            Text(filter.name, style: notInLibraryFont),
            Spacer(),
            DropdownButtonHideUnderline(
              child: DropdownButton<SettingOption>(
                value: filter.options[x],
                items: buildDropDownMenuItems(filter.options),
                dropdownColor: Colors.grey[800],
                style: TextStyle(fontSize: 20),
                onChanged: (value) {
                  Provider.of<BrowseProvider>(context, listen: false)
                      .save(filter.selector, filter.type, value);
                },
              ),
            ),
          ],
        );
      case 3:
        return (filter.name.contains("Tag"))
            ? buildIncludeExclude(context, filter.options)
            : tags(context, filter.options, filter.name, filter.selector);

      default:
        return Center(
          child: Text(
            "API Error",
            style: notInLibraryFont,
          ),
        );
    }
  }

  Widget buildIncludeExclude(context, List<SettingOption> options) {
    return Column(
      children: [
        tags(context, options, "Included Tags", "included_tags"),
        SizedBox(
          height: 20.h,
        ),
        tags(context, options, "Excluded Tags", "excluded_tags")
      ],
    );
  }

  Widget tags(
      BuildContext context, List options, String title, String selector) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            "$title",
            style: notInLibraryFont,
            // maxLines: 1,
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            // alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiSelect(
                    options: options,
                    selector: "$selector",
                  ),
                ),
              ),
              child: Text(
                (Provider.of<BrowseProvider>(context)
                            .data["$selector"]
                            .length ==
                        0)
                    ? "Select"
                    : "${Provider.of<BrowseProvider>(context).data["$selector"].map((element) => element.name).join(", ")}",
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 20,
                ),
                textAlign: TextAlign.end,
                softWrap: true,
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MultiSelect extends StatefulWidget {
  final List<SettingOption> options;
  final String selector;

  const MultiSelect({Key key, this.options, @required this.selector})
      : super(key: key);

  @override
  _MultiSelectState createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  List<SettingOption> selectedItems = List();

  @override
  void initState() {
    List<SettingOption> options =
        Provider.of<BrowseProvider>(context, listen: false)
            .data['${widget.selector}']
            .cast<SettingOption>();
    selectedItems += options;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multi-Select"),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.all(7.w),
            child: Row(
              children: [
                InkWell(
                  child: Center(
                      child: Text(
                    "Clear",
                    style: notInLibraryFont,
                  )),
                  onTap: () {
                    setState(() {
                      selectedItems.clear();
                      Provider.of<BrowseProvider>(context, listen: false)
                          .save(widget.selector, 3, selectedItems);
                    });
                  },
                ),
                SizedBox(
                  width: 10.w,
                ),
                InkWell(
                  child: Center(
                      child: Text(
                    "Done",
                    style: notInLibraryFont,
                  )),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        child: ListView.builder(
            itemCount: widget.options.length,
            itemBuilder: (_, int index) {
              SettingOption settingOption = widget.options[index];
              return ListTile(
                title: Text(settingOption.name),
                onTap: () {
                  setState(() {
                    (selectedItems.contains(settingOption))
                        ? selectedItems.remove(settingOption)
                        : selectedItems.add(settingOption);

                    Provider.of<BrowseProvider>(context, listen: false)
                        .save(widget.selector, 3, selectedItems);
                  });
                },
                trailing: Icon(
                  Icons.check,
                  color: (selectedItems.contains(settingOption))
                      ? Colors.purple
                      : Colors.transparent,
                ),
              );
            }),
      ),
    );
  }
}
