// Comic Highlight
class ComicHighlight {
  String title;
  String thumbnail;
  String link;
  String selector;

  ComicHighlight(this.title, this.link, this.thumbnail, this.selector);

  Map<String, String> toMap() {
    return {
      "name": title,
      "thumbnail": thumbnail,
      "link": link,
      "selector": selector
    };
  }

  ComicHighlight.fromMap(Map<String, dynamic> map) {
    title = map['Title'];
    thumbnail = map['Thumbnail'];
    link = map['Link'];
    selector = map['Selector'];
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
  List data;
  List images;
  int pages;

  ComicProfile(
      this.title,
      this.thumbnail,
      this.description,
      this.source,
      this.chapters,
      this.chapterCount,
      this.pages,
      this.images,
      this.altTitles,
      this.data,
      this.genres,
      this.status,
      this.artist,
      this.author);

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

    // Custom data for hentai sources
    data = map['Data'];
    images = map['Images'];
    pages = map['Pages'];
  }

  Map<String, dynamic> toMap() {
    return {
      "name": title,
      "thumbnail": thumbnail,
      "description": description,
      "author": author,
      "artist": artist,
      "status": status,
      "genres": genres,
      "altTitles": altTitles,
      "chapterCount": chapterCount,
      "source": source,
      "data": data,
      "images": images,
      "pages": pages
    };
  }
}
