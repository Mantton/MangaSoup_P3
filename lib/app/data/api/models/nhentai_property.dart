import 'package:mangasoup_prototype_3/app/data/api/models/tag.dart';

class DescriptionProperty{
  String name;
  List<Tag> tags;

  DescriptionProperty.fromMap(Map<String, dynamic> map){
    name = map['name'];
    tags = (map["tags"] as List).map((e) => Tag.fromMap(e)).toList();
  }

  Map<String, dynamic> toMap(){
    return {
      "name": name,
      "tags" : tags.map((e) => e.toMap()).toList(),
    };
  }
}