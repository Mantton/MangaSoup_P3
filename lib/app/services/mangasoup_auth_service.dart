import 'package:dio/dio.dart';
import 'package:mangasoup_prototype_3/app/data/preference/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MangaSoupAuth {
  static bool _isDev = true;
  static String _productionAddress = "http://auth.mangasoup.net";
  static String _localAddress = "http://127.0.0.1:4700";

  static String _address() => _isDev ? _localAddress : _productionAddress;
  static BaseOptions _options = BaseOptions(
    baseUrl: _address(),
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);

  /// LOGIN
  Future<bool> login(String username, String password) async {
    bool status = false;

    try {
      Response response = await _dio.post("/api/login",
          data: {"username": username, "password": password});
      Map data = response.data['data'];
      Map tokens = response.data['tokens'];

      String un = data['username'];
      String id = data['id'];
      List roles = data['roles'];

      String token = tokens["access_token"];
      String refreshToken = tokens['refresh_token'];

      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setString(PreferenceKeys.MS_ACCESS_TOKEN, token);
      return true;
    } catch (err, trace) {
      print(err);
      throw "Error";
    }
  }
}
