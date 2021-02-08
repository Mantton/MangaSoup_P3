class MALOauth{
  String refreshToken;
  String accessToken;
  String tokenType;
  num expiresIn;

  bool isExpired()=> (DateTime.now().microsecondsSinceEpoch/1000) > expiresIn;
}