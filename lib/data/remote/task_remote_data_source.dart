import 'package:check_in_app/core/errors/failure.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TaskRemoteDataSource {
  Future<List<Task>> fetchTasks();

  Future<Task> upsert(Task task);
}

class FirestoreTaskRemoteDataSource implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreTaskRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<Task>> fetchTasks() async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      return snapshot.docs
          .map(
            (doc) => Task.fromJson({
              ...doc.data(),
              'id': doc.id,
            }),
          )
          .toList();
    } catch (e) {
      throw AppFailure(
        type: FailureType.network,
        message: 'Failed to fetch remote tasks',
        cause: e,
      );
    }
  }

  @override
  Future<Task> upsert(Task task) async {
    try {
      final payload = task.copyWith(syncStatus: SyncStatus.synced).toJson();
      await _firestore.collection('tasks').doc(task.id).set(payload);
      return task.copyWith(syncStatus: SyncStatus.synced);
    } catch (e) {
      throw AppFailure(
        type: FailureType.network,
        message: 'Failed to sync task',
        cause: e,
      );
    }
  }
}

class MockTaskRemoteDataSource implements TaskRemoteDataSource {
  @override
  Future<List<Task>> fetchTasks() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const [];
  }

  @override
  Future<Task> upsert(Task task) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return task.copyWith(syncStatus: SyncStatus.synced);
  }
}
