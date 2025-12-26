import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/core/result.dart';
import 'package:check_in_app/data/local/checkin_local_data_source.dart';
import 'package:check_in_app/data/remote/checkin_remote_data_source.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/repositories/checkin_repository.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  final CheckInLocalDataSource local;
  final CheckInRemoteDataSource remote;
  final bool remoteEnabled;

  CheckInRepositoryImpl({
    required this.local,
    required this.remote,
    required this.remoteEnabled,
  });

  @override
  Future<Result<CheckIn>> create(CheckIn checkIn) async {
    final toSave = checkIn.copyWith(
      syncStatus: remoteEnabled ? SyncStatus.pending : SyncStatus.localOnly,
    );
    try {
      await local.upsert(toSave);
      return Result.success(toSave);
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Unable to save check-in',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<CheckIn>>> forTask(String taskId) async {
    try {
      return Result.success(local.forTask(taskId));
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Failed to load check-ins',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<List<CheckIn>>> pending() async {
    try {
      return Result.success(local.pending());
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Unable to read pending check-ins',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> syncPending() async {
    final pendingCheckIns = local.pending();
    if (pendingCheckIns.isEmpty) return Result.successVoid();
    if (!remoteEnabled) {
      for (final checkIn in pendingCheckIns) {
        await local.upsert(checkIn.copyWith(syncStatus: SyncStatus.synced));
      }
      return Result.successVoid();
    }

    try {
      for (final checkIn in pendingCheckIns) {
        final synced = await remote.push(checkIn);
        await local.upsert(synced.copyWith(syncStatus: SyncStatus.synced));
      }
      return Result.successVoid();
    } catch (e) {
      for (final checkIn in pendingCheckIns) {
        await local.upsert(checkIn.copyWith(syncStatus: SyncStatus.failed));
      }
      return Result.failure(
        AppFailure(
          type: FailureType.network,
          message: 'Unable to sync check-ins, will retry.',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> markSynced(String id) async {
    try {
      await local.updateStatus(id, SyncStatus.synced);
      return Result.successVoid();
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Failed to mark synced',
          cause: e,
        ),
      );
    }
  }

  @override
  Future<Result<void>> markFailed(String id) async {
    try {
      await local.updateStatus(id, SyncStatus.failed);
      return Result.successVoid();
    } catch (e) {
      return Result.failure(
        AppFailure(
          type: FailureType.storage,
          message: 'Failed to mark failed',
          cause: e,
        ),
      );
    }
  }
}
