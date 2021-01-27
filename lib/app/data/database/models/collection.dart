class Collection {
  int id;
  String name;
  int order;

  Collection({this.name}) {
    this.id = null;
    this.order = null;
  }

  Collection createDefault() => Collection(name: "Default");

  Collection.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    order = map['order'];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "order": order,
    };
  }
}
