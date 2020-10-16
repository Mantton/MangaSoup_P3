import 'package:flutter/cupertino.dart';

class TestProvider extends ChangeNotifier {
  List<String> names = [];

  addName(String value) async {
    names.add(value);
    notifyListeners();
  }
}
