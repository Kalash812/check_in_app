import 'package:check_in_app/data/local/hive_storage.dart';
import 'package:check_in_app/domain/models/task.dart';

class TaskLocalDataSource {
  final HiveStorage storage;

  TaskLocalDataSource(this.storage);

  List<Task> getTasks() {
    return storage.readTasks().map(Task.fromJson).toList();
  }

  Future<void> upsertTask(Task task) => storage.upsertTask(task.toJson());

  Future<void> saveTasks(List<Task> tasks) async {
    await storage.saveTasks(tasks.map((t) => t.toJson()).toList());
  }

  Task? getById(String id) {
    final data = storage.readTask(id);
    return data == null ? null : Task.fromJson(data);
  }
}
