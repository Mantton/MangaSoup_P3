import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';

class ChapterCommentsPage extends StatefulWidget {
  final List<ChapterComment> comments;

  const ChapterCommentsPage({Key key, this.comments}) : super(key: key);

  @override
  _ChapterCommentsPageState createState() => _ChapterCommentsPageState();
}

class _ChapterCommentsPageState extends State<ChapterCommentsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Comments",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontSize: 20,
                    color: Colors.white70,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    CupertinoIcons.clear,
                    // size: 30,
                    color: Colors.grey,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
          Expanded(
            child: widget.comments.isEmpty
                ? isEmptyView()
                : CommentList(c: widget.comments),
          ),
          Container(
            height: 50,
            child: TextField(
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Add Comment...",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[900]),
                  gapPadding: 5,
                ),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(150),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget isEmptyView() => Center(
        child: Text("Be the first to comment!"),
      );
}

class CommentList extends StatefulWidget {
  final List<ChapterComment> c;

  const CommentList({Key key, this.c}) : super(key: key);

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  List<ChapterComment> comments = List();

  @override
  void initState() {
    comments = List.of(widget.c);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.separated(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, index) => commentTile(comments[index]),
        separatorBuilder: (_, index) => SizedBox(height: 5),
        itemCount: comments.length,
      ),
    );
  }

  Widget commentTile(ChapterComment comment) => Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(7.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author,
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: "Lato",
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      comment.body,
                      style: TextStyle(
                        // color: Colors.white70,
                        fontFamily: "Lato",
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite_border),
                  onPressed: null,
                ),
                comment.likes > 1
                    ? Text(
                        comment.likes.toString(),
                      )
                    : Container(),
              ],
            )
          ],
        ),
      );
}
