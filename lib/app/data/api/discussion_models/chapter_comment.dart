class ChapterComment {
  int likes;
  CommentAuthor author;
  String chapterLink;
  String body;
  String id;
  bool likedByUser;
  int replies;
  DateTime datePosted;

  ChapterComment({this.author, this.body, this.chapterLink, this.likes});

  ChapterComment.fromMap(Map<String, dynamic> map) {
    author = CommentAuthor.fromMap(map['author']);
    likes = map['likes'];
    replies = map['replies'];
    chapterLink = map['chapter_link'];
    body = map['body'];
    id = map['comment_id'];
    likedByUser = map['liked_by_user'] ?? false;
  }
}

class CommentAuthor {
  int level;
  String username;
  String avatar;
  String id;

  CommentAuthor.fromMap(Map<String, dynamic> map) {
    level = map['level'];
    username = map['username'];
    avatar = map['avatar'];
    id = map['id'];
  }
}