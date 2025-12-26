import 'package:check_in_app/domain/models/session.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated, error }

class AuthState extends Equatable {
  final AuthStatus status;
  final Session? session;
  final String? message;

  const AuthState({required this.status, this.session, this.message});

  factory AuthState.unknown() => const AuthState(status: AuthStatus.unknown);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  AuthState copyWith({AuthStatus? status, Session? session, String? message}) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, session, message];
}
