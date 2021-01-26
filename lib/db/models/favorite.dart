
class Comic {

  // Identifiers
  int id;
  String  title;
  String link;

  // Source Info
  String source;
  String selector;

  // App
  bool isFavorite = false;
  int viewerMode = 0;

  // Update Info
  int chapterCount = 0;
  int updateCount = 0;

  Comic({this.id, this.title, this.link, this.source, this.selector});




}