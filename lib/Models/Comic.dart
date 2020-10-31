// Comic Highlight
import 'dart:convert';

class ComicHighlight {
  String title;
  String thumbnail;
  String link;
  String selector;
  String source;

  ComicHighlight(
      this.title, this.link, this.thumbnail, this.selector, this.source);

  Map<String, String> toMap() {
    return {
      "title": title,
      "thumbnail": thumbnail,
      "link": link,
      "selector": selector,
      "source": source,
    };
  }

  ComicHighlight.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    thumbnail = map['thumbnail'];
    link = map['link'];
    selector = map['selector'];
    source = map['source'];
  }
}

class ComicHistory {
  int id;
  ComicHighlight highlight;
  List<Map> readChapters;
  Map lastStop;

  ComicHistory(this.id, this.highlight, this.readChapters, this.lastStop);

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "comicHighlight": jsonEncode(highlight.toMap()),
      "readChapters": jsonEncode(readChapters),
      "lastStop": jsonEncode(lastStop),
      "link": highlight.link,
    };
  } // Convert to Map

  ComicHistory.fromMap(Map<String, dynamic> map) {
    highlight = ComicHighlight.fromMap(jsonDecode(map['comicHighlight']));
    id = map['id'];
    readChapters = jsonDecode(map['readChapters']);
    lastStop = jsonDecode(map['lastStop']);
  }
}

class ComicProfile {
  String title;
  String description;
  String thumbnail;
  var altTitles;
  var author;
  var artist;
  String status;
  List genres;
  int chapterCount;
  List chapters;
  String source;
  List properties;
  List images;
  int pageCount;
  String link;
  String uploadDate;
  String galleryId;
  bool containsBooks;
  int bookCount;
  List books;

  ComicProfile(
      this.title,
      this.thumbnail,
      this.description,
      this.source,
      this.chapters,
      this.chapterCount,
      this.pageCount,
      this.images,
      this.altTitles,
      this.properties,
      this.genres,
      this.status,
      this.artist,
      this.author,
      this.link,
      this.uploadDate,
      this.galleryId,
      this.containsBooks,
      this.bookCount,
      this.books);

  ComicProfile.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    description = map['summary'];
    thumbnail = map['thumbnail'];
    altTitles = map['alt_title'];
    author = map['author'];
    artist = map['artist'];
    status = map['status'];
    genres = map['tags'];
    chapterCount = map['chapter_count'];
    source = map['source'];
    chapters = map['chapters'];
    link = map['link'];

    // Custom data for hentai sources
    properties = map['properties'];
    images = map['images'];
    pageCount = map['page_count'];
    galleryId = map['gallery_id'];
    uploadDate = map['upload_date'];

    // Custom data for sources with books
    bookCount = map['book_count'];
    books = map['books'];
    containsBooks = map['contains_books'];
  }

  Map<String, dynamic> toMap() {
    return {
      "name": title,
      "thumbnail": thumbnail,
      "summary": description,
      "author": author,
      "artist": artist,
      "status": status,
      "genres": genres,
      "alt_title": altTitles,
      "chapter_count": chapterCount,
      "source": source,
      "properties": properties,
      "images": images,
      "pages": pageCount,
      "chapters": chapters,
      "link": link,
      "upload_date": uploadDate,
      "gallery_id": galleryId,
      "book_count": bookCount,
      "books": books,
      "contains_books": containsBooks,
    };
  }
}
