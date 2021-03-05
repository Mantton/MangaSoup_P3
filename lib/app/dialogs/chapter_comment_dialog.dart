import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangasoup_prototype_3/Components/PlatformComponents.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';
import 'package:mangasoup_prototype_3/app/screens/comments/chapter_comments.dart';
import 'package:mangasoup_prototype_3/app/services/discuss/discussions_manager.dart';

chapterCommentsDialog({@required BuildContext context, String link}) {
  showModalBottomSheet(
    context: context,
    builder: (_) => Container(
      height: MediaQuery.of(_).size.height * .70,
      color: Color.fromRGBO(10, 10, 10, 1.0),
      child: CommentListFutureBuilder(
        link: link,
      ),
    ),
  );
}

class CommentListFutureBuilder extends StatefulWidget {
  final String link;

  const CommentListFutureBuilder({Key key, this.link}) : super(key: key);

  @override
  _CommentListFutureBuilderState createState() =>
      _CommentListFutureBuilderState();
}

class _CommentListFutureBuilderState extends State<CommentListFutureBuilder> {
  Future<List<ChapterComment>> pointer;

  Future<List<ChapterComment>> getComments() async {
    List<ChapterComment> v = List();
    try {
      v = await DiscussionManager().getChapterComments(widget.link, 1);
    } catch (err) {
      throw err;
    }
    return v;
  }

  @override
  void initState() {
    pointer = getComments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pointer,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(
            child: LoadingIndicator(),
          );
        else if (snapshot.hasError)
          return Center(
            child: InkWell(
              child: Text(
                "An Error Occurred\nTap to Retry",
                textAlign: TextAlign.center,
              ),
              onTap: () {
                setState(() {
                  pointer = getComments();
                });
              },
            ),
          );
        else if (snapshot.hasData)
          return ChapterCommentsPage(
            comments: snapshot.data,
            chapterLink: widget.link,
          );
        else
          return Center(child: Text("You Should not be seeing this."));
      },
    );
  }
}
