import 'package:check_in_app/core/constants/hive_boxes.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveStorage {
  final Box _tasksBox;
  final Box _checkInsBox;
  final Box _sessionBox;
  final Box _metaBox;

  HiveStorage._(
    this._tasksBox,
    this._checkInsBox,
    this._sessionBox,
    this._metaBox,
  );

  @visibleForTesting
  HiveStorage.test({
    required Box tasks,
    required Box checkIns,
    required Box session,
    required Box meta,
  }) : this._(tasks, checkIns, session, meta);

  static Future<HiveStorage> init() async {
    await Hive.initFlutter();
    final tasks = await Hive.openBox(HiveBoxes.tasks);
    final checkIns = await Hive.openBox(HiveBoxes.checkIns);
    final session = await Hive.openBox(HiveBoxes.session);
    final meta = await Hive.openBox(HiveBoxes.meta);
    return HiveStorage._(tasks, checkIns, session, meta);
  }

  bool get isSeeded => _metaBox.get('seeded') == true;

  Future<void> markSeeded() => _metaBox.put('seeded', true);

  Future<void> clearAll() async {
    await Future.wait([
      _tasksBox.clear(),
      _checkInsBox.clear(),
      _sessionBox.clear(),
    ]);
  }

  // Tasks
  List<Map<String, dynamic>> readTasks() {
    return _tasksBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Map<String, dynamic>? readTask(String id) {
    final data = _tasksBox.get(id);
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<void> upsertTask(Map<String, dynamic> task) {
    return _tasksBox.put(task['id'] as String, task);
  }

  Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    final entries = {
      for (final task in tasks) task['id'] as String: task,
    };
    await _tasksBox.putAll(entries);
  }

  // Check-ins
  List<Map<String, dynamic>> readCheckIns() {
    return _checkInsBox.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  List<Map<String, dynamic>> readCheckInsForTask(String taskId) {
    return readCheckIns().where((c) => c['taskId'] == taskId).toList();
  }

  Future<void> upsertCheckIn(Map<String, dynamic> checkIn) {
    return _checkInsBox.put(checkIn['id'] as String, checkIn);
  }

  // Session
  Map<String, dynamic>? readSession() {
    final data = _sessionBox.get('session');
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<void> writeSession(Map<String, dynamic> session) {
    return _sessionBox.put('session', session);
  }

  Future<void> clearSession() => _sessionBox.delete('session');
}
