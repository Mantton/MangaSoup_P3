import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';
import 'package:mangasoup_prototype_3/app/services/discuss/discussions_manager.dart';

class ChapterCommentsPage extends StatefulWidget {
  final List<ChapterComment> comments;
  final String chapterLink;

  const ChapterCommentsPage(
      {Key key, @required this.comments, @required this.chapterLink})
      : super(key: key);

  @override
  _ChapterCommentsPageState createState() => _ChapterCommentsPageState();
}

class _ChapterCommentsPageState extends State<ChapterCommentsPage> {
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    comments = widget.comments;
  }

  TextEditingController _controller;
  List<ChapterComment> comments = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
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
            child: comments.isEmpty
                ? isEmptyView()
                : CommentList(comments: comments),
          ),
          Container(
            height: 50,
            child: TextField(
              controller: _controller,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: "Add Comment...",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.transparent,
                  ),
                  gapPadding: 5,
                ),
              ),
              inputFormatters: [
                LengthLimitingTextInputFormatter(150),
              ],
              onSubmitted: (body) {
                if (body.isEmpty)
                  BotToast.showCustomNotification(
                    toastBuilder: (_) => Container(
                      padding: EdgeInsets.all(5.0),
                      height: 45,
                      width: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[900],
                      ),
                      child: Center(
                        child: Text(
                          "Enter a comment",
                          style: notInLibraryFont,
                        ),
                      ),
                    ),
                  );
                else {
                  DiscussionManager()
                      .addComment(body, widget.chapterLink)
                      .then((value) {
                    setState(() {
                      comments.insert(0, value);
                    });
                  }).catchError(
                    (err) => showSnackBarMessage(
                      "Failed to Comment",
                      error: true,
                    ),
                  );
                }

                setState(() {
                  _controller.clear();
                });
              },
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
  final List<ChapterComment> comments;

  const CommentList({Key key, this.comments}) : super(key: key);

  @override
  _CommentListState createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.separated(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, index) => commentTile(widget.comments[index]),
        separatorBuilder: (_, index) => SizedBox(height: 5),
        itemCount: widget.comments.length,
      ),
    );
  }

  Widget commentTile(ChapterComment comment) => GestureDetector(
        onTap: () => debugPrint(comment.id),
        onLongPress: () => showOptionsMenu(comment),
        child: Padding(
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
        ),
      );

  showOptionsMenu(ChapterComment comment) => showPlatformModalSheet(
        context: context,
        builder: (_) => PlatformWidget(
          cupertino: (_, __) => CupertinoActionSheet(
              cancelButton: CupertinoButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                CupertinoActionSheetAction(
                  child: Text("Copy"),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: comment.body),
                    );
                    Navigator.pop(context);
                    showSnackBarMessage("Copied!");
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text("Report"),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
        ),
      );
}
