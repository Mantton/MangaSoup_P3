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