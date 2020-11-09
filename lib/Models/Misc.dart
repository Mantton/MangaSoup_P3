class Chapter {
  String name;
  String date;
  String link;
  String maker;

  Chapter(this.name, this.link, this.date, this.maker);

  Chapter.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    link = map['link'];
    date = map['date'];
    maker = map['maker'] ?? "";
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "link": link, "date": date, "maker": maker};
  }
}

class Book {
  String name;
  List chapters;
  String range;
  int generatedLength;

  Book(this.name, this.range, this.chapters, this.generatedLength);

  // List<Chapter> _generateChapters(List<Map> chpts) {
  //   List generated = [];
  //   for (int i = 0; i < chpts.length; i++) {
  //     generated.add(Chapter.fromMap(chpts[i]));
  //   }
  //   return generated;
  // }

  Map<String, dynamic> toMap() {
    return {
      "book_title": name,
      "book_range": range,
      "chapters": chapters,
      "generated_length": generatedLength
    };
  }

  Book.fromMap(Map<String, dynamic> map) {
    name = map['book_title'];
    range = map['book_range'];
    chapters = map['chapters'];
    generatedLength = map['generated_length'];
  }
}


class Tag {
  String name;
  var link;
  String selector;

  Tag(this.name, this.link, this.selector);


  Tag.fromMap(Map<String, dynamic> map) {
    name = map['tag'] ?? map['genre'] ?? map['name'];
    link = map['link'];
    selector = map['selector'];
  }

}

class ImageSearchResult {
  String title;
  String selector;
  String source;
  String chapter;
  String author;
  String similarity;
  String thumbnail;
  int mCID;
  String chapterLink;

  ImageSearchResult(this.title, this.selector, this.source, this.chapter,
      this.author, this.thumbnail, this.similarity, this.mCID, this.chapterLink);


  ImageSearchResult.fromMap(Map<String, dynamic> map) {
    title = map['data']['source'];
    selector = "mangadex";
    source = "MangaDex";
    chapter = map['data']['part'].toString().replaceAll(" - ", "");
    author = map['data']['author'];
    similarity = map['header']['similarity'];
    thumbnail = map['header']['thumbnail'];
    mCID = map['data']["md_id"];
    chapterLink = map['data']['ext_urls'][0];
  }

}