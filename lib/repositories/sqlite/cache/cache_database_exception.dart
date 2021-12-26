class CacheDatabaseException implements Exception {
  String cause;

  CacheDatabaseException({
    required this.cause,
  });
}
