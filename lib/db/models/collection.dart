
import 'package:flutter/cupertino.dart';

class Collection{
  int id;
  String name;
  int order;
  int nsfw; // One for True, Zero for False

  // Create
  Collection({@required this.name,@required this.order ,@required this.nsfw});


  Collection createDefault(){
    return Collection(name: "Default", nsfw: 0, order: 0);
  }

}