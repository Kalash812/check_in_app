import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';

class CheckInLocalDataSource {
  final HiveStorage storage;

  CheckInLocalDataSource(this.storage);

  List<CheckIn> forTask(String taskId) {
    return storage.readCheckInsForTask(taskId).map(CheckIn.fromJson).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> upsert(CheckIn checkIn) {
    return storage.upsertCheckIn(checkIn.toJson());
  }

  List<CheckIn> pending() {
    return storage
        .readCheckIns()
        .map(CheckIn.fromJson)
        .where((c) => c.syncStatus == SyncStatus.pending || c.syncStatus == SyncStatus.failed)
        .toList();
  }

  Future<void> updateStatus(String id, SyncStatus status) async {
    final data = storage.readCheckIns().firstWhere(
      (c) => c['id'] == id,
      orElse: () => {},
    );
    if (data.isEmpty) return;
    final current = CheckIn.fromJson(data);
    await storage.upsertCheckIn(current.copyWith(syncStatus: status).toJson());
  }
}
