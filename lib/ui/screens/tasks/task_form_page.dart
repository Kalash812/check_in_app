import 'package:check_in_app/data/seed/seed_data.dart';
import 'package:check_in_app/domain/enums.dart';
import 'package:check_in_app/domain/models/app_user.dart';
import 'package:check_in_app/domain/models/task.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  final AppUser currentUser;

  const TaskFormPage({super.key, this.task, required this.currentUser});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _locationController;
  late DateTime _dueDate;
  late TaskPriority _priority;
  late TaskStatus _status;
  late String _assignedTo;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _locationController = TextEditingController(text: task?.location ?? '');
    _dueDate = task?.dueDate ?? DateTime.now().add(const Duration(days: 2));
    _priority = task?.priority ?? TaskPriority.medium;
    _status = task?.status ?? TaskStatus.open;
    _assignedTo = task?.assignedTo ?? SeedData.users.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit task' : 'New task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location / site'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: TaskPriority.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _priority = v ?? _priority),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<TaskStatus>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: TaskStatus.values
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(s.label),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Due date'),
                child: Row(
                  children: [
                    Text('${_dueDate.month}/${_dueDate.day}/${_dueDate.year}'),
                    const Spacer(),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text('Pick'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _assignedTo,
                decoration: const InputDecoration(labelText: 'Assign to'),
                items: SeedData.users
                    .map(
                      (user) => DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.name} (${user.role.label})'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _assignedTo = value);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save changes' : 'Create task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (chosen != null) {
      setState(() => _dueDate = chosen);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _status,
      dueDate: _dueDate,
      priority: _priority,
      location: _locationController.text.trim(),
      assignedTo: _assignedTo,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );
    Navigator.of(context).pop(task);
  }
}
