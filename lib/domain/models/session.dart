import 'package:check_in_app/domain/models/app_user.dart';

class Session {
  final AppUser user;
  final String token;
  final DateTime expiresAt;

  const Session({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'token': token,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
