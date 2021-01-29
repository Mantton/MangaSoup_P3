import 'package:mangasoup_prototype_3/app/data/api/models/nhentai_property.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';

import 'book.dart';
import 'chapter.dart';

class Profile {
  String title;
  String description;
  String thumbnail;
  var altTitles;
  var author;
  var artist;
  String status;
  List<Tag> genres;
  int chapterCount;
  List<Chapter> chapters;
  String source;
  String selector;
  List properties;
  List<String> images;
  int pageCount;
  String link;
  String uploadDate;
  String galleryId;
  bool containsBooks;
  int bookCount;
  List<Book> books;

  Profile(
    this.title,
    this.thumbnail,
    this.description,
    this.source,
    this.selector,
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
    this.books,
  );

  Profile.fromMap(Map<String, dynamic> map) {
    containsBooks = map['contains_books'];
    bool isHentai = false;
    if (containsBooks == null) {
      isHentai = true;
    }

    title = map['title'];
    description = map['summary'];
    thumbnail = map['thumbnail'];
    altTitles = map['alt_title'];
    author = map['author'];
    artist = map['artist'];
    status = map['status'];
    genres = map['tags'] != null
        ? (map['tags'] as List).map((e) => Tag.fromMap(e)).toList()
        : null;
    chapterCount = isHentai
        ? 0
        : !containsBooks
            ? map['chapter_count']
            : map["max_chapter_count"];
    source = map['source'];
    selector = map['selector'];
    link = map['link'];

    // Chapters
    chapters = isHentai
        ? null
        : !containsBooks
            ? (map['chapters'] as List)
                .map((e) => Chapter.fromMap(e, title))
                .toList()
            : null;
    if (chapters!= null)
      // Sort Chapters
      chapters.sort((a, b)=>b.generatedNumber.compareTo(a.generatedNumber));

    // Custom data for hentai sources
    properties = isHentai
        ? (map['properties'] as List)
            .map((e) => DescriptionProperty.fromMap(e))
            .toList()
        : null;
    images = (map['images'] as List)?.map((item) => item as String)?.toList();
    pageCount = map['page_count'];
    galleryId = map['gallery_id'];
    uploadDate = map['upload_date'];

    // Custom data for sources with books
    bookCount = map['book_count'];
    books = isHentai
        ? null
        : containsBooks
            ? (map['books'] as List).map((e) => Book.fromMap(e, title)).toList()
            : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": title,
      "thumbnail": thumbnail,
      "summary": description,
      "author": author,
      "artist": artist,
      "status": status,
      "genres": genres.map((e) => e.toMap()).toList(),
      "alt_title": altTitles,
      "chapter_count": chapterCount,
      "source": source,
      "properties": properties,
      "images": images,
      "pages": pageCount,
      "chapters": chapters.map((e) => e.toMap()).toList(),
      "link": link,
      "upload_date": uploadDate,
      "gallery_id": galleryId,
      "book_count": bookCount,
      "books": books.map((e) => e.toMap()).toList(),
      "contains_books": containsBooks,
    };
  }
}
