import 'package:mangasoup_prototype_3/app/data/api/models/nhentai_property.dart';
import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';

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
  bool isCustom;

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
    this.isCustom,
  );

  Profile.fromMap(Map<String, dynamic> map) {
    isCustom = map['is_custom'];
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
    chapterCount = isCustom ? 0 : map['chapter_count'];

    source = map['source'];
    selector = map['selector'];
    link = map['link'];

    // Chapters
    chapters = isCustom
        ? null
        : (map['chapters'] as List)
            .map((e) => Chapter.fromMap(e, title))
            .toList();

    if (chapters != null)
      // Sort Chapters
      chapters.sort((a, b) => b.generatedNumber.compareTo(a.generatedNumber));

    // Custom data for hentai sources
    properties = isCustom
        ? (map['properties'] as List)
            .map((e) => DescriptionProperty.fromMap(e))
            .toList()
        : null;
    images = (map['images'] as List)?.map((item) => item as String)?.toList();
    pageCount = map['page_count'];
    galleryId = map['gallery_id'];
    uploadDate = map['upload_date'];
  }

  Map<String, dynamic> toMap() {
    return {
      "is_custom": isCustom,
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
    };
  }
}
