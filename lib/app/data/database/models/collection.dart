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

  Collection createDefault() => Collection(name: "Default");

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
