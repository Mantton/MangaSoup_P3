import 'package:dio/dio.dart';

class ServerException implements Exception {
  String cause;

  ServerException(this.cause);
}

class NoConnectionException implements Exception {}

class MissingMangaDexSession implements Exception {
  String _message;

  MissingMangaDexSession(
      [String message = 'You are not logged in to MangaDex']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}

class ErrorManager {
  static analyze(var error) {
    if (error is DioError) {
      DioError err = error;
      if (err.response.statusCode != null) {
        if (err.response.statusCode == 400)
          throw "Bad Request";
        else if (err.response.statusCode == 401)
          throw "Unauthorized Request";
        else if (err.response.statusCode == 403)
          throw "Unauthorized Request";
        else if (err.response.statusCode == 404)
          throw "Resource not Fount";
        else if (err.response.statusCode == 410)
          throw "Resource is no longer available on this server";
        else if (err.response.statusCode == 500)
          throw "MangaSoup Server Error\nContact Dev";
        else if (err.response.statusCode == 502)
          throw "Bad Gateway, Server might be under heavy load";
        else
          throw "Requested Server is currently down";
      } else {
        print(err);
        throw "API Manager encountered an error";
      }
    } else {
      if (error is MissingMangaDexSession)
        throw "The resource you are request requires MangaDex Authentication";
      else {
        print(error);
        throw error.toString();
      }
    }
  }
}
