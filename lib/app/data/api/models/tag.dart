class Tag {
  String name;
  String  link;
  String selector;
  bool isClickable;

  Tag(this.name, this.link, this.selector, this.isClickable);


  Tag.fromMap(Map<String, dynamic> map) {
    name = map['tag'] ?? map['genre'] ?? map['name'];
    link = map['link'];
    selector = map['selector'];
    isClickable = link.isNotEmpty;
  }

  Map<String , dynamic> toMap(){
    return {
      "name": name,
      "link": link,
      "selector"  : selector,
      "is_clickable": isClickable
    };
  }

}