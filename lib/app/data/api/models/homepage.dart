class HomePage {
  String header;
  String subHeader;
  List comics;

  HomePage(this.header, this.subHeader, this.comics);

  HomePage.fromMap(Map<String, dynamic> map) {
    header = map['header'];
    subHeader = map['subheader'];
    comics = map['comics'];
  }

  Map<String, dynamic> toMap() {
    return {"header": header, "subheader": subHeader, "comics": comics};
  }
}