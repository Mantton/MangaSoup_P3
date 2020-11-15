class ImageChapter {
  List<String> images;
  String referer;
  String source;
  int count;

  ImageChapter({this.images, this.referer, this.source, this.count});

  Map<String, dynamic> toMap() {
    return {
      "images": images,
      "referer": referer,
      "source": source,
      "count": count
    };
  }

  ImageChapter.fromMap(Map<String, dynamic> map) {
    images = (map['images'] as List)?.map((item) => item as String)?.toList();
    referer = map['referer'];
    source = map['source'];
    count = map['count'];
  }
}
