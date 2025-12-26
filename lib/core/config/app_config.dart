class AppConfig {
  const AppConfig._();

  /// Toggle to enable Firebase Auth once real credentials are added.
  static const bool enableFirebaseAuth = true;

  /// Toggle remote sync (Firestore) for tasks/check-ins once credentials exist.
  static const bool enableFirebaseRemote = true;

  /// Page size used for lazy loading tasks.
  static const int pageSize = 12;
}
