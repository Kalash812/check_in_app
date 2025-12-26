import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CheckInRemoteDataSource {
  Future<CheckIn> push(CheckIn checkIn);
}

class FirestoreCheckInRemoteDataSource implements CheckInRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreCheckInRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<CheckIn> push(CheckIn checkIn) async {
    try {
      final payload = checkIn.copyWith(syncStatus: SyncStatus.synced).toJson();
      await _firestore.collection('checkins').doc(checkIn.id).set(payload);
      return checkIn.copyWith(syncStatus: SyncStatus.synced);
    } catch (e) {
      throw AppFailure(
        type: FailureType.network,
        message: 'Failed to sync check-in',
        cause: e,
      );
    }
  }
}

class MockCheckInRemoteDataSource implements CheckInRemoteDataSource {
  @override
  Future<CheckIn> push(CheckIn checkIn) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return checkIn.copyWith(
      syncStatus: SyncStatus.synced,
    );
  }
}
