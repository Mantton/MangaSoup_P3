class History{
  int id;
  int comicId;
  // int chapterId;
  DateTime lastRead;

  History({this.comicId}){
    this.id = null;
    this.lastRead = DateTime.now() ;

  }

  History.fromMap(Map<String, dynamic> map){
    id = map['id'];
    comicId = map['comic_id'];
    lastRead = DateTime.fromMicrosecondsSinceEpoch(map['last_read']);
  }

  Map<String, dynamic > toMap()=>
      {
        "id": id,
        "comic_id": comicId,
        "last_read": lastRead.microsecondsSinceEpoch
      };

}