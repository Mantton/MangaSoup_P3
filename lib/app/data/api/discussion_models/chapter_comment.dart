class ChapterComment {
  int likes;
  String author;
  String chapterLink;
  String body;
  String id;

  ChapterComment({this.author, this.body, this.chapterLink, this.likes});

  ChapterComment.fromMap(Map<String, dynamic> map) {
    author = map['author_name'];
    likes = map['likes'];
    chapterLink = map['chapter_link'];
    body = map['body'];
    id = map['comment_id'];
  }
}
