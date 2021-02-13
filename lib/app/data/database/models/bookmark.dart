class BookMark{
  int id;
  int comicId;
  int page;
  String chapterName;
  String chapterLink;

  BookMark(this.comicId, this.page, this.chapterLink, this.chapterName);

  BookMark.fromMap(Map<String, dynamic> map){
    id = map['id'];
    comicId = map['comic_id'];
    page = map['page'];
    chapterName = map['chapter_name'];
    chapterLink = map['chapter_link'];
  }

  Map<String, dynamic>toMap()=>{
    "id": id,
    "comic_id": comicId,
    "page": page,
    "chapter_name":chapterName,
    "chapter_link":chapterLink,
  };
}