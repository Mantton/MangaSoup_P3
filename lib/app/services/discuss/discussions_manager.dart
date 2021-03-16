import 'package:dio/dio.dart';

class DiscussionManager {
  static bool _isDev = true;
  static String _productionAddress = "https://topics.mangasoup.net";
  static String _localAddress = "http://127.0.0.1:3000";
  final String _jwt =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMjg5MTMzM2YzY"
      "TQ2ZWE2NGNiNzJiNyIsImlhdCI6MTYxNDkwMDgyMSwiZXhwIjoxNjE0OT"
      "g3MjIxfQ.S9zsSOoYJv6aeVKZsq6Vp5UEOdGckM5E4ZBXetps1j8";

  static String _address() => _isDev ? _localAddress : _productionAddress;

  static BaseOptions _options = BaseOptions(
    baseUrl: _address(),
    connectTimeout: 50000,
    receiveTimeout: 50000,
  );
  final Dio _dio = Dio(_options);




}
