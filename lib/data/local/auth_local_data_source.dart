import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/domain/models/session.dart';

class AuthLocalDataSource {
  final HiveStorage storage;

  AuthLocalDataSource(this.storage);

  Future<void> cacheSession(Session session) async {
    await storage.writeSession(session.toJson());
  }

  Session? readSession() {
    final data = storage.readSession();
    if (data == null) return null;
    return Session.fromJson(data);
  }

  Future<void> clear() => storage.clearSession();
}
