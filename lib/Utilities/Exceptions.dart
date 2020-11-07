class ServerException implements Exception {
  String cause;

  ServerException(this.cause);
}

class NoConnectionException implements Exception{

}

class MissingMangaDexSession implements Exception {

  String _message;

  MissingMangaDexSession([String message = 'You are not logged in to MangaDex']) {
    this._message = message;
  }

  @override
  String toString() {
    return _message;
  }
}