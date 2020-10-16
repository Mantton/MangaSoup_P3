class ServerException implements Exception {
  String cause;

  ServerException(this.cause);
}

class NoConnectionException implements Exception{

}