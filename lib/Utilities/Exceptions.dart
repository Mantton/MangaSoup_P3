import 'dart:io';

import 'package:dio/dio.dart';

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
      if (err.response != null) {
        if (err.response.statusCode == 400)
          throw "Bad Request";
        else if (err.response.statusCode == 401)
          throw "Unauthorized Request";
        else if (err.response.statusCode == 403)
          throw "Unauthorized Request";
        else if (err.response.statusCode == 404)
          throw "Resource not Fount";
        else if (err.response.statusCode == 410)
          throw "Resource is no longer available on this server.";
        else if (err.response.statusCode == 422)
          throw "Incorrect Schema used in request.";
        else if (err.response.statusCode == 500) {
          print(err.response.data);
          throw "MangaSoup Server Error\nContact Dev.";
        } else if (err.response.statusCode == 502)
          throw "Bad Gateway, Server might be under heavy load.";
        else if (err.response.statusCode == 463)
          throw "CloudFare Bypass Validation Failed";
        else
          throw "Requested Server is currently down";
      } else {
        if (err.error is SocketException) {
          throw "Failed to Connect to MangaSoup Servers";
        } else {
          print(err);
          throw "MangaSoup encountered an Undefined Network Error.";
        }
      }
    } else {
      if (error is MissingMangaDexSession)
        throw "The resource you are requesting requires MangaDex Authentication.";
      else {
        print(error.runtimeType);
        print(error);
        if (error is String)
          throw "$error";
        else {
          print(error);
          throw "Undefined Processing Error";
        }
      }
    }
  }
}
