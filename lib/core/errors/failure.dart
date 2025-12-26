enum FailureType {
  network,
  auth,
  validation,
  storage,
  notFound,
  permission,
  unknown,
}

class AppFailure {
  final FailureType type;
  final String message;
  final Object? cause;

  const AppFailure({
    required this.type,
    required this.message,
    this.cause,
  });

  @override
  String toString() => 'Failure($type): $message';
}
