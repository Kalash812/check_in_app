import 'package:check_in_app/domain/enums.dart';

class CheckIn {
  final String id;
  final String taskId;
  final String notes;
  final CheckInCategory category;
  final String? photoPath;
  final double latitude;
  final double longitude;
  final DateTime createdAt;
  final String createdBy;
  final SyncStatus syncStatus;

  const CheckIn({
    required this.id,
    required this.taskId,
    required this.notes,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.createdBy,
    this.photoPath,
    this.syncStatus = SyncStatus.pending,
  });

  CheckIn copyWith({
    String? id,
    String? taskId,
    String? notes,
    CheckInCategory? category,
    String? photoPath,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? createdBy,
    SyncStatus? syncStatus,
  }) {
    return CheckIn(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'notes': notes,
        'category': category.name,
        'photoPath': photoPath,
        'latitude': latitude,
        'longitude': longitude,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'syncStatus': syncStatus.name,
      };

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      notes: json['notes'] as String,
      category: CheckInCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String? ?? CheckInCategory.progress.name),
        orElse: () => CheckInCategory.progress,
      ),
      photoPath: json['photoPath'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String? ?? '',
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == (json['syncStatus'] as String? ?? SyncStatus.pending.name),
        orElse: () => SyncStatus.pending,
      ),
    );
  }
}
