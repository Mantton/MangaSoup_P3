// Comic Highlight
class ComicHighlight {
  String title;
  String thumbnail;
  String link;

  ComicHighlight(this.title, this.link, this.thumbnail);

  Map<String, String> toMap() {
    return {
      "name": title,
      "thumbnail": thumbnail,
      "link": link,
    };
  }

  ComicHighlight.fromMap(Map<String, dynamic> map) {
    title = map['Title'];
    thumbnail = map['Thumbnail'];
    link = map['Link'];
  }
}

class ComicProfile {
  String title;
  String description;
  String thumbnail;
  List altTitles;
  String author;
  String artist;
  String status;
  List genres;
  int chapterCount;
  List chapters;
  String source;

  ComicProfile.fromMap(Map<String, dynamic> map) {
    title = map['Title'];
    description = map['Description'];
    thumbnail = map['Thumbnail'];
    altTitles = map['Alternative Titles'];
    author = map['Author(s)'];
    artist = map['Artist(s)'];
    status = map['Status'];
    genres = map['Genre(s)'];
    chapterCount = map['Number of Chapters'];
    source = map['Source'];
  }
}
