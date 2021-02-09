import 'package:mangasoup_prototype_3/app/util/generateChapterNumber.dart';

class Chapter {
  String name;
  String date;
  String link;
  String maker;
  bool openInBrowser;
  double generatedNumber;

  Chapter(this.name, this.link, this.date, this.maker){
    openInBrowser = false;
  }

  Chapter.fromMap(Map<String, dynamic> map, String comicTitle) {
    name = map['name'];
    link = map['link'];
    date = map['date'] ?? "";
    maker = map['maker'] ?? "";
    openInBrowser = map['in_browser'] ?? false;
    generatedNumber = ChapterRecognition().parseChapterNumber(name, comicTitle);

  }

  Map<String, dynamic> toMap() {
    return {"name": name, "link": link, "date": date, "maker": maker, "chapter_number": generatedNumber};
  }
}