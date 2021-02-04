import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Screens/Tags/TagComics.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class TagWidget extends StatelessWidget {
  final Tag tag;

  const TagWidget({Key key,@required this.tag}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // push to tag page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TagComicsPage(
              tag: tag,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(4.0.w),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(5.w),),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: AutoSizeText(
                tag.name,
                maxLines: 2,
                softWrap: true,
                wrapWords: false,
                // minFontSize: 5.sp,
                // maxFontSize: 100.sp,
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
