// Comic Highlight
class ComicHighlight {
  String title;
  String thumbnail;
  String link;
  String selector;
  String source;
  bool isHentai;
  String imageReferer;
  int updateCount;

  ComicHighlight(
      this.title, this.link, this.thumbnail, this.selector, this.source, this.isHentai, this.imageReferer, {this.updateCount});

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "thumbnail": thumbnail,
      "link": link,
      "selector": selector,
      "source": source,
      "is_hentai":isHentai,
      "image_referer":imageReferer
    };
  }

  ComicHighlight.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    thumbnail = map['thumbnail'];
    link = map['link'];
    selector = map['selector'];
    source = map['source'];
    isHentai = map['is_hentai'];
    imageReferer = map['image_referer'];
  }
}
