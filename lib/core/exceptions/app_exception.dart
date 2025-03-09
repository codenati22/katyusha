class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class DuplicateUsernameException extends AppException {
  DuplicateUsernameException() : super('Username is already taken');
}
