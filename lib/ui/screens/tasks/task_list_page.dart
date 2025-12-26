import 'package:check_in_app/core/utils/date_formatter.dart';
import 'package:check_in_app/core/utils/status_color.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/session.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:check_in_app/domain/usecases/fetch_tasks_usecase.dart';
import 'package:check_in_app/domain/usecases/get_task_usecase.dart';
import 'package:check_in_app/domain/usecases/update_task_status_usecase.dart';
import 'package:check_in_app/domain/usecases/upsert_task_usecase.dart';
import 'package:check_in_app/domain/usecases/fetch_checkins_usecase.dart';
import 'package:check_in_app/domain/usecases/create_checkin_usecase.dart';
import 'package:check_in_app/ui/screens/tasks/task_detail_page.dart';
import 'package:check_in_app/ui/screens/tasks/task_form_page.dart';
import 'package:check_in_app/viewmodel/auth/auth_cubit.dart';
import 'package:check_in_app/viewmodel/checkin/checkin_cubit.dart';
import 'package:check_in_app/viewmodel/connectivity/connectivity_cubit.dart';
import 'package:check_in_app/di/locator.dart';
import 'package:check_in_app/viewmodel/connectivity/connectivity_state.dart';
import 'package:check_in_app/viewmodel/sync/sync_cubit.dart';
import 'package:check_in_app/viewmodel/tasks/task_detail_cubit.dart';
import 'package:check_in_app/viewmodel/tasks/task_list_cubit.dart' as tlc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskListPage extends StatelessWidget {
  final Session session;

  const TaskListPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final isMember = session.user.role == UserRole.member;
    return BlocProvider(
      create: (context) => tlc.TaskListCubit(
        fetchTasksUseCase: FetchTasksUseCase(getIt()),
        updateTaskStatusUseCase: UpdateTaskStatusUseCase(getIt()),
        upsertTaskUseCase: UpsertTaskUseCase(getIt()),
        assignedTo: isMember ? session.user.id : null,
      )..loadInitial(),
      child: _TaskListView(
        session: session,
        isMember: isMember,
      ),
    );
  }
}

class _TaskListView extends StatefulWidget {
  final Session session;
  final bool isMember;

  const _TaskListView({
    required this.session,
    required this.isMember,
  });

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SyncCubit>().sync();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      context.read<tlc.TaskListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks • ${widget.session.user.role.label}'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            onPressed: () {
              context.read<SyncCubit>().sync();
              context.read<tlc.TaskListCubit>().refresh();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => context.read<AuthCubit>().logout(),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<tlc.TaskListCubit, tlc.TaskListState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error!)),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _StatusFilterChip(
                                label: 'All',
                                selected: state.filter == null,
                                onSelected: (_) =>
                                    context.read<tlc.TaskListCubit>().applyFilter(null),
                              ),
                              const SizedBox(width: 8),
                              ...TaskStatus.values.map(
                                (status) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _StatusFilterChip(
                                    label: status.label,
                                    selected: state.filter == status,
                                    onSelected: (_) =>
                                        context.read<tlc.TaskListCubit>().applyFilter(status),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<TaskSort>(
                        value: state.sort,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(
                            value: TaskSort.dueDate,
                            child: Text('Due date'),
                          ),
                          DropdownMenuItem(
                            value: TaskSort.priority,
                            child: Text('Priority'),
                          ),
                        ],
                        onChanged: (sort) {
                          if (sort != null) {
                            context.read<tlc.TaskListCubit>().applySort(sort);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                BlocBuilder<ConnectivityCubit, ConnectivityState>(
                  builder: (context, conn) {
                    final color = conn.isOnline
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.errorContainer;
                    final text = conn.isOnline ? 'Online' : 'Offline mode · pending sync';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            conn.isOnline ? Icons.wifi : Icons.wifi_off,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(text),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<tlc.TaskListCubit>().refresh(),
                    child: state.loading && state.tasks.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: state.tasks.length + (state.loadingMore ? 1 : 0),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              if (index >= state.tasks.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              final task = state.tasks[index];
                              return _TaskCard(
                                task: task,
                                onTap: () => _openTaskDetail(context, task),
                                onStatusChange: (status) =>
                                    context.read<tlc.TaskListCubit>().updateStatus(task.id, status),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: widget.isMember
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final saved = await Navigator.of(context).push<Task?>(
                  MaterialPageRoute(
                    builder: (_) => TaskFormPage(
                      currentUser: widget.session.user,
                    ),
                  ),
                );
                if (saved != null && context.mounted) {
                  context.read<tlc.TaskListCubit>().upsertTask(saved);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('New task'),
      ),
    );
  }

  void _openTaskDetail(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => TaskDetailCubit(
                getTaskUseCase: GetTaskUseCase(getIt()),
                fetchCheckInsUseCase: FetchCheckInsUseCase(getIt()),
              )..load(task.id),
            ),
            BlocProvider(
              create: (context) => CheckInCubit(
                createCheckInUseCase: CreateCheckInUseCase(getIt()),
                taskId: task.id,
                userId: widget.session.user.id,
              )..loadLocation(),
            ),
          ],
          child: TaskDetailPage(
            taskId: task.id,
            currentUser: widget.session.user,
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus> onStatusChange;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 68,
                decoration: BoxDecoration(
                  color: taskStatusColor(task.status, scheme),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        _Badge(label: task.priority.label, color: scheme.primaryContainer),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place_outlined, size: 16, color: scheme.outline),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task.location,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Icon(Icons.calendar_month, size: 16, color: scheme.outline),
                        const SizedBox(width: 4),
                        Text(DateFormatter.short(task.dueDate)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        DropdownButton<TaskStatus>(
                          value: task.status,
                          underline: const SizedBox(),
                          items: TaskStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.label),
                                ),
                              )
                              .toList(),
                          onChanged: (status) {
                            if (status != null) onStatusChange(status);
                          },
                        ),
                        const SizedBox(width: 8),
                        _Badge(
                          label: task.syncStatus.label,
                          color: syncStatusColor(task.syncStatus, scheme).withOpacity(0.16),
                        ),
                      ],
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

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
