// Comic Highlight
import 'package:mangasoup_prototype_3/app/data/enums/mangadex_follow_category.dart';

class ComicHighlight {
  String title;
  String thumbnail;
  String link;
  String selector;
  String source;
  bool isHentai;
  String imageReferer;
  int updateCount;
  int unreadCount;
  String mangadexFollowType;

  ComicHighlight(this.title, this.link, this.thumbnail, this.selector,
      this.source, this.isHentai, this.imageReferer,
      {this.updateCount, this.unreadCount});

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

  ComicHighlight.fromMangaDex(Map map){
    title = map['mangaTitle'];
    isHentai = map['isHentai'];
    thumbnail = map['mainCover'];
    selector = "mangadex";
    source = "MangaDex";
    imageReferer = "mangadex.org";
    link = "https://mangadex.org/title/" + map['mangaId'].toString();
    mangadexFollowType = getCategory(map['followType']);
  }
}
