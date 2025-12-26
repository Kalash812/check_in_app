import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:check_in_app/domain/models/task.dart';

class SeedData {
  const SeedData._();

  static final users = <AppUser>[
    const AppUser(
      id: 'u-admin',
      email: 'admin@checkin.dev',
      name: 'Avery Admin',
      role: UserRole.admin,
    ),
    const AppUser(
      id: 'u-member',
      email: 'member@checkin.dev',
      name: 'Member 1',
      role: UserRole.member,
    ),
  ];

  static final credentials = <String, String>{
    'admin@checkin.dev': 'password123',
    'member@checkin.dev': 'password123',
  };

  static List<Task> tasks() {
    final now = DateTime.now();
    return [
      Task(
        id: 'T-001',
        title: 'Inspect north site scaffolding',
        description: 'Verify guard rails, toe boards, and signage at north site.',
        status: TaskStatus.open,
        dueDate: now.add(const Duration(days: 2)),
        priority: TaskPriority.high,
        location: 'North Plant - Dock 3',
        assignedTo: users[1].id,
        updatedAt: now.subtract(const Duration(hours: 1)),
        syncStatus: SyncStatus.synced,
      ),
      Task(
        id: 'T-002',
        title: 'Safety toolbox talk',
        description: 'Daily safety talk for crew B with sign-off.',
        status: TaskStatus.inProgress,
        dueDate: now.add(const Duration(days: 1)),
        priority: TaskPriority.medium,
        location: 'Staging area trailer',
        assignedTo: users[1].id,
        updatedAt: now.subtract(const Duration(hours: 5)),
        syncStatus: SyncStatus.synced,
      ),
      Task(
        id: 'T-003',
        title: 'Punch list - level 4',
        description: 'Close open punch items for apartments 401-406.',
        status: TaskStatus.open,
        dueDate: now.add(const Duration(days: 4)),
        priority: TaskPriority.medium,
        location: 'Level 4 hallway',
        assignedTo: users[1].id,
        updatedAt: now.subtract(const Duration(days: 1)),
        syncStatus: SyncStatus.synced,
      ),
      Task(
        id: 'T-004',
        title: 'Generator service',
        description: 'Coordinate vendor access and isolate panels.',
        status: TaskStatus.done,
        dueDate: now.subtract(const Duration(days: 1)),
        priority: TaskPriority.low,
        location: 'Roof mechanical room',
        assignedTo: users[0].id,
        updatedAt: now.subtract(const Duration(days: 2)),
        syncStatus: SyncStatus.synced,
      ),
    ];
  }
}
