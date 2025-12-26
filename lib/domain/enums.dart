enum UserRole { admin, member }

enum TaskStatus { open, inProgress, done }

enum TaskPriority { low, medium, high }

enum CheckInCategory { safety, progress, issue, other }

enum SyncStatus { pending, synced, failed, localOnly }

enum TaskSort { dueDate, priority }

extension TaskStatusX on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.open:
        return 'Open';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }
}

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  int get weight {
    switch (this) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
    }
  }
}

extension CheckInCategoryX on CheckInCategory {
  String get label {
    switch (this) {
      case CheckInCategory.safety:
        return 'Safety';
      case CheckInCategory.progress:
        return 'Progress';
      case CheckInCategory.issue:
        return 'Issue';
      case CheckInCategory.other:
        return 'Other';
    }
  }
}

extension SyncStatusX on SyncStatus {
  String get label {
    switch (this) {
      case SyncStatus.pending:
        return 'Pending';
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.failed:
        return 'Failed';
      case SyncStatus.localOnly:
        return 'Local Only';
    }
  }
}

extension UserRoleX on UserRole {
  String get label => this == UserRole.admin ? 'Admin' : 'Member';
}
