class ImageChapter {
  List<String> images;
  String referer;
  String source;
  int count;
  String link;

  ImageChapter({this.images, this.referer, this.source, this.count, this.link});

  Map<String, dynamic> toMap() {
    return {
      "images": images,
      "referer": referer,
      "source": source,
      "count": count,
      "link": link
    };
  }

  ImageChapter.fromMap(Map<String, dynamic> map) {
    images = (map['images'] as List)?.map((item) => item as String)?.toList();
    referer = map['referer'];
    source = map['source'];
    count = map['count'];
    link = map['link'];
  }
}
