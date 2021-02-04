class Collection {
  int id;
  String name;
  int order;
  bool updateEnabled;

  Collection({this.name}) {
    this.id = null;
    this.order = null;
    this.updateEnabled = false;
  }

  static Collection createDefault() {
    Collection col = Collection(name: "Default");
    col.order = 0;
    return col;
  }

  Collection.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    order = map['sort'];
    updateEnabled = map['update_enabled'] == 1 ? true : false;
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "sort": order,
      "update_enabled": updateEnabled ? 1 : 0,
    };
  }
}
