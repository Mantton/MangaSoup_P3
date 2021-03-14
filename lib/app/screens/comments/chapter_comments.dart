import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mangasoup_prototype_3/Components/Messages.dart';
import 'package:mangasoup_prototype_3/app/constants/fonts.dart';
import 'package:mangasoup_prototype_3/app/data/api/discussion_models/chapter_comment.dart';
import 'package:mangasoup_prototype_3/app/data/preference/preference_provider.dart';
import 'package:mangasoup_prototype_3/app/screens/mangasoup/mangasoup_auth_screen.dart';
import 'package:mangasoup_prototype_3/app/services/mangasoup_combined_testing.dart';
import 'package:provider/provider.dart';

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
    return Column(
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
              : Container(
                  padding: EdgeInsets.all(3),
                  child: CommentList(comments: comments)),
        ),
        Container(
          height: 50,
          child: TextField(
            controller: _controller,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Add Comment...",
              contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                _addComment(body, context);
              }

              setState(() {
                _controller.clear();
              });
            },
          ),
        )
      ],
    );
  }

  void _addComment(String body, BuildContext context) {
    MSCombined().addComment(body, widget.chapterLink, context).then((value) {
      setState(() {
        comments.insert(0, value);
      });
    }).catchError((err) {
      if (err == "MissingMangaSoupAccessToken") {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => MangaSoupSignInSignUP(), fullscreenDialog: true),
        ).then((value) {
          if (value == null || value == false)
            showSnackBarMessage("You are not signed in", error: true);
          else
            _addComment(body, context);
        });
      } else {
        showSnackBarMessage(err.toString(), error: true);
      }
    });
  }

  authorizationDialog() => showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text("Authorize"),
          content: Text(
              "MangaSoup Auth token was not detected, authorize using MangaDex?"),
          actions: [
            PlatformDialogAction(
                child: Text("Cancel"), onPressed: () => Navigator.pop(context)),
            PlatformDialogAction(
                child: Text("Proceed"), onPressed: () => Navigator.pop(context))
          ],
        ),
      );

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
    _comments = widget.comments;
  }

  List<ChapterComment> _comments = [];

  @override
  Widget build(BuildContext context) {
    return CupertinoScrollbar(
      child: ListView.separated(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (_, index) => commentTile(_comments[index]),
        separatorBuilder: (_, index) => SizedBox(height: 5),
        itemCount: _comments.length,
      ),
    );
  }

  Widget commentTile(ChapterComment comment) => GestureDetector(
    onTap: () => debugPrint(comment.id),
        onLongPress: () => showOptionsMenu(comment),
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.all(2.5),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(comment.author.avatar),
                backgroundColor: Colors.grey[900],
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.author.username,
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
              TextButton(
                style: ButtonStyle(
                    overlayColor:
                        MaterialStateProperty.all<Color>(Colors.transparent)),
                onPressed: () {
                  setState(() {
                    if (comment.likedByUser)
                      comment.likes--;
                    else
                      comment.likes++;
                    comment.likedByUser = !comment.likedByUser;
                  });
                  try {
                    MSCombined().toggleLike(comment, context);
                  } catch (err) {
                    print(err);
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      !comment.likedByUser
                          ? Icons.favorite_border
                          : Icons.favorite,
                      color:
                          comment.likedByUser ? Colors.redAccent : Colors.grey,
                    ),
                    comment.likes >= 1
                        ? Text(
                            comment.likes.toString(),
                            style: TextStyle(
                              color: comment.likedByUser
                                  ? Colors.redAccent
                                  : Colors.grey,
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  showOptionsMenu(ChapterComment comment) => showPlatformModalSheet(
        context: context,
        builder: (_) => PlatformWidget(
          cupertino: (_, __) => CupertinoActionSheet(
              cancelButton: CupertinoActionSheetAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
                isDefaultAction: true,
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
                Consumer<PreferenceProvider>(
                  builder: (context, provider, _) => provider.msUser != null &&
                          (provider.msUser.level > 1 ||
                              provider.msUser.id == comment.author.id)
                      ? CupertinoActionSheetAction(
                          onPressed: () => MSCombined()
                              .deleteComment(comment, context)
                              .then((value) {
                            setState(() {
                              _comments.remove(comment);
                            });
                            Navigator.pop(context);
                            showSnackBarMessage("Removed!", success: true);
                          }).catchError(
                                  (onError) => showSnackBarMessage(onError)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(provider.msUser.level > 1
                                  ? "Remove"
                                  : "Delete"),
                              provider.msUser.level > 1
                                  ? Icon(
                                      Icons.shield,
                                      color: Colors.red,
                                    )
                                  : Container(),
                            ],
                          ),
                          isDestructiveAction: provider.msUser.level > 1,
                        )
                      : Container(),
                ),
              ]),
        ),
      );
}
