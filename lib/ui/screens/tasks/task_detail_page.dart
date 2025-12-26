import 'package:check_in_app/core/utils/date_formatter.dart';
import 'package:check_in_app/core/utils/status_color.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/models/check_in.dart';
import 'package:check_in_app/domain/usecases/update_task_status_usecase.dart';
import 'package:check_in_app/domain/usecases/upsert_task_usecase.dart';
import 'package:check_in_app/ui/screens/tasks/task_form_page.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_cubit.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_state.dart';
import 'package:check_in_app/viewmodel/tasks/task_detail_cubit.dart';
import 'package:check_in_app/viewmodel/tasks/task_detail_state.dart';
import 'package:check_in_app/di/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;
  final AppUser currentUser;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task detail')),
      body: BlocBuilder<TaskDetailCubit, TaskDetailState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.task == null) {
            return const Center(child: Text('Task not found'));
          }
          final task = state.task!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TaskHeader(task: task),
              if (currentUser.role == UserRole.admin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _editTask(context, task),
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Edit task'),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _InfoTile(
                    icon: Icons.access_time,
                    label: 'Due',
                    value: DateFormatter.short(task.dueDate),
                  ),
                  _InfoTile(
                    icon: Icons.flag,
                    label: 'Priority',
                    value: task.priority.label,
                  ),
                  _InfoTile(
                    icon: Icons.sync,
                    label: 'Sync',
                    value: task.syncStatus.label,
                    color: syncStatusColor(task.syncStatus, Theme.of(context).colorScheme),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Update status:'),
                  const SizedBox(width: 12),
                  DropdownButton<TaskStatus>(
                    value: task.status,
                    items: TaskStatus.values
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.label),
                          ),
                        )
                        .toList(),
                    onChanged: (status) {
                      if (status != null) _updateStatus(context, task, status);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Check-ins',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (state.checkIns.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No check-ins yet. Add one below.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...state.checkIns.map((c) => _CheckInTile(checkIn: c)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _openCheckInSheet(context),
                icon: const Icon(Icons.edit_location_alt_outlined),
                label: const Text('New check-in'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openCheckInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: BlocProvider.value(
          value: context.read<CheckInCubit>(),
          child: _CheckInForm(
            onSaved: (checkIn) {
              context.read<TaskDetailCubit>().addCheckIn(checkIn);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, Task task, TaskStatus status) async {
    final result = await UpdateTaskStatusUseCase(getIt())(task.id, status);
    if (result.isSuccess && context.mounted) {
      context.read<TaskDetailCubit>().load(task.id);
    }
  }

  Future<void> _editTask(BuildContext context, Task task) async {
    final updated = await Navigator.of(context).push<Task?>(
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          task: task,
          currentUser: currentUser,
        ),
      ),
    );
    if (updated != null && context.mounted) {
      await UpsertTaskUseCase(getIt())(updated);
      if (context.mounted) {
        context.read<TaskDetailCubit>().load(task.id);
      }
    }
  }
}

class _TaskHeader extends StatelessWidget {
  final Task task;

  const _TaskHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: taskStatusColor(task.status, scheme).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(task.status.label),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.description),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(task.location)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: ${DateFormatter.withTime(task.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color ?? scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInTile extends StatelessWidget {
  final CheckIn checkIn;

  const _CheckInTile({required this.checkIn});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  checkIn.category.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: syncStatusColor(checkIn.syncStatus, scheme).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    checkIn.syncStatus.label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(checkIn.notes),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(DateFormatter.withTime(checkIn.createdAt)),
                const Spacer(),
                Icon(Icons.location_on_outlined, size: 14, color: scheme.outline),
                Text('${checkIn.latitude.toStringAsFixed(3)}, ${checkIn.longitude.toStringAsFixed(3)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInForm extends StatefulWidget {
  final ValueChanged<CheckIn> onSaved;

  const _CheckInForm({required this.onSaved});

  @override
  State<_CheckInForm> createState() => _CheckInFormState();
}

class _CheckInFormState extends State<_CheckInForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckInCubit, CheckInFormState>(
      listener: (context, state) {
        if (state.success) {
          _formKey.currentState?.reset();
          _notesController.clear();
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Text(
                'New check-in',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Notes'),
                onChanged: context.read<CheckInCubit>().updateNotes,
                validator: (value) =>
                    value != null && value.trim().length >= 10 ? null : 'At least 10 characters',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: CheckInCategory.values
                    .map(
                      (category) => ChoiceChip(
                        label: Text(category.label),
                        selected: state.category == category,
                        onSelected: (_) => context.read<CheckInCubit>().updateCategory(category),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.read<CheckInCubit>().pickPhoto(),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(state.photoPath == null ? 'Add photo' : 'Retake'),
                  ),
                  const SizedBox(width: 8),
                  if (state.photoPath != null)
                    Text(
                      'Attached',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  state.locationLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          state.latitude == null
                              ? 'Location required'
                              : '${state.latitude!.toStringAsFixed(3)}, ${state.longitude!.toStringAsFixed(3)}',
                        ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<CheckInCubit>().loadLocation(),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: state.submitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        final checkIn = await context.read<CheckInCubit>().submit();
                        if (checkIn != null && context.mounted) {
                          widget.onSaved(checkIn);
                        }
                      },
                child: state.submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save (offline first)'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
