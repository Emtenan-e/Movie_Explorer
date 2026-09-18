class ServerException implements Exception{

  final int statusCode;

  ServerException({
    required this.statusCode
  });



}