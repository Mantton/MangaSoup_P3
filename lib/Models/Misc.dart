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
    maker = map['maker'];
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
