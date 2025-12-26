import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/data/seed/seed_data.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteAuthResult {
  final AppUser user;
  final String token;
  final DateTime expiresAt;

  RemoteAuthResult({
    required this.user,
    required this.token,
    required this.expiresAt,
  });
}

abstract class AuthRemoteDataSource {
  Future<RemoteAuthResult> signIn(String email, String password);
  Future<void> signOut();
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final Map<String, AppUser> roleOverrides;

  FirebaseAuthRemoteDataSource({
    FirebaseAuth? auth,
    required this.roleOverrides,
  }) : _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<RemoteAuthResult> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw AppFailure(type: FailureType.auth, message: 'Invalid user');
      }
      final idTokenResult = await firebaseUser.getIdTokenResult(true);
      final token = idTokenResult.token ?? '';
      final expiresAt = idTokenResult.expirationTime ??
          DateTime.now().add(const Duration(hours: 1));

      final role = roleOverrides[email] ??
          SeedData.users.firstWhere(
            (u) => u.email == email,
            orElse: () => SeedData.users.first,
          );

      final appUser = role.copyWith(
        id: firebaseUser.uid,
        email: email,
        name: firebaseUser.displayName ?? role.name,
      );

      return RemoteAuthResult(
        user: appUser,
        token: token,
        expiresAt: expiresAt,
      );
    } on FirebaseAuthException catch (e) {
      throw AppFailure(
        type: FailureType.auth,
        message: e.message ?? 'Authentication failed',
        cause: e,
      );
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<RemoteAuthResult> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final expectedPassword = SeedData.credentials[email];
    if (expectedPassword == null || expectedPassword != password) {
      throw AppFailure(
        type: FailureType.auth,
        message: 'Invalid credentials',
      );
    }
    final user = SeedData.users.firstWhere(
      (u) => u.email == email,
      orElse: () => SeedData.users.last,
    );

    return RemoteAuthResult(
      user: user,
      token: 'local-token-${user.id}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );
  }

  @override
  Future<void> signOut() async {}
}
