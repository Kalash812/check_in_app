import 'package:check_in_app/domain/enums.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime dueDate;
  final TaskPriority priority;
  final String location;
  final String assignedTo;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.priority,
    required this.location,
    required this.assignedTo,
    required this.updatedAt,
    this.syncStatus = SyncStatus.localOnly,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? dueDate,
    TaskPriority? priority,
    String? location,
    String? assignedTo,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      assignedTo: assignedTo ?? this.assignedTo,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'status': status.name,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'location': location,
        'assignedTo': assignedTo,
        'updatedAt': updatedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String? ?? TaskStatus.open.name),
        orElse: () => TaskStatus.open,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String? ?? TaskPriority.medium.name),
        orElse: () => TaskPriority.medium,
      ),
      location: json['location'] as String? ?? '',
      assignedTo: json['assignedTo'] as String? ?? '',
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == (json['syncStatus'] as String? ?? SyncStatus.localOnly.name),
        orElse: () => SyncStatus.localOnly,
      ),
    );
  }
}
