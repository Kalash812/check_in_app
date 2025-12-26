import 'package:check_in_app/domain/enums.dart';
import 'package:flutter/material.dart';

Color taskStatusColor(TaskStatus status, ColorScheme scheme) {
  switch (status) {
    case TaskStatus.open:
      return scheme.primary;
    case TaskStatus.inProgress:
      return scheme.tertiary;
    case TaskStatus.done:
      return scheme.secondary;
  }
}

Color syncStatusColor(SyncStatus status, ColorScheme scheme) {
  switch (status) {
    case SyncStatus.synced:
      return scheme.secondary;
    case SyncStatus.pending:
      return scheme.primary;
    case SyncStatus.failed:
      return scheme.error;
    case SyncStatus.localOnly:
      return scheme.outline;
  }
}
