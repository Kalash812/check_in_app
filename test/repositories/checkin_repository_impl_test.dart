import 'package:check_in_app/data/local/checkin_local_data_source.dart';
import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/data/remote/checkin_remote_data_source.dart';
import 'package:check_in_app/data/repositories/checkin_repository_impl.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';

void main() {
  late HiveStorage storage;
  late CheckInLocalDataSource local;

  final checkIn = CheckIn(
    id: 'c1',
    taskId: 't1',
    notes: 'A valid note here',
    category: CheckInCategory.issue,
    latitude: 1.0,
    longitude: 2.0,
    createdAt: DateTime.now(),
    createdBy: 'u1',
  );

  setUp(() async {
    await setUpTestHive();
    storage = HiveStorage.test(
      tasks: await Hive.openBox('tasks_box'),
      checkIns: await Hive.openBox('checkins_box'),
      session: await Hive.openBox('session_box'),
      meta: await Hive.openBox('meta_box'),
    );
    local = CheckInLocalDataSource(storage);
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  test('create stores check-in locally with localOnly status when remote disabled', () async {
    final repository = CheckInRepositoryImpl(
      local: local,
      remote: MockCheckInRemoteDataSource(),
      remoteEnabled: false,
    );
    final result = await repository.create(checkIn);
    expect(result.isSuccess, true);
    expect(result.data?.syncStatus, SyncStatus.localOnly);
    final pending = await repository.pending();
    expect(pending.data, isEmpty);
  });

  test('syncPending marks pending check-ins as synced', () async {
    final repository = CheckInRepositoryImpl(
      local: local,
      remote: MockCheckInRemoteDataSource(),
      remoteEnabled: true,
    );
    await repository.create(checkIn.copyWith(syncStatus: SyncStatus.pending));
    final pending = await repository.pending();
    expect(pending.data?.length, 1);
    await repository.syncPending();
    final after = await repository.pending();
    expect(after.data?.length, 0);
    final list = await repository.forTask('t1');
    expect(list.data?.first.syncStatus, SyncStatus.synced);
  });
}
