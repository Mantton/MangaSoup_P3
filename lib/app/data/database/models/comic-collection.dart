class ComicCollection{
  int id;
  int comicId;
  int collectionId;

  ComicCollection({this.comicId, this.collectionId}){
    this.id = null;
  }

  ComicCollection.fromMap(Map<String, dynamic> map){
      id = map['id'];
      comicId = map['comic_id'];
      collectionId = map['collection_id'];
  }

  Map<String, dynamic> toMap() =>
      {
        "id": id,
        "comic_id": comicId,
        "collection_id": collectionId
      };

}