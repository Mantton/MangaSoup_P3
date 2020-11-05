class SourceSetting {
  String name;
  int type;
  var selector;
  List options;

  SourceSetting(this.name, this.type, this.selector, this.options);

  SourceSetting.fromMap(Map map) {
    name = map['name'];
    type = map['type'];
    selector = map['selector'];
    options = generateOptions(map['options']);
  }

  generateOptions(List options) {
    List<SettingOption> generated = List();
    for (var map in options) {
      generated.add(SettingOption.fromMap(map));
    }
    return generated;
  }
}

class SettingOption {
  String name;
  var selector;
  var value;

  SettingOption(this.name, this.selector, this.value);

  SettingOption.fromMap(Map map) {
    name = map['name'];
    selector = map['selector'];
    value = map['value'];
  }

  Map toMap() {
    return {
      "name": name,

      "selector": selector,
      "value": value,
    };
  }
}
