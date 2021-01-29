import 'package:mangasoup_prototype_3/app/data/api/models/chapter.dart';

class Book {
  String name;
  List<Chapter> chapters;
  String range;
  int generatedLength;

  Book(this.name, this.range, this.chapters, this.generatedLength);

  Map<String, dynamic> toMap() {
    return {
      "book_title": name,
      "book_range": range,
      "chapters": chapters.map((e) => e.toMap()).toList(),
      "generated_length": generatedLength
    };
  }

  Book.fromMap(Map<String, dynamic> map,String comicTitle) {
    name = map['book_title'];
    range = map['book_range'];
    chapters = (map['chapters'] as List).map((e) => Chapter.fromMap(e, comicTitle)).toList();
    if (chapters!= null)
      // Sort Chapters
      chapters.sort((a, b)=>b.generatedNumber.compareTo(a.generatedNumber));
    generatedLength = map['generated_length'];
  }
}