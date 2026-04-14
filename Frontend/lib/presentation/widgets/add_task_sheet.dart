import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';
import 'package:todo_list_app/core/notification_service.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int _priority = 1; // Medium
  DateTime? _reminderDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Thêm công việc mới', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Mô tả (tùy chọn)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Ưu tiên: '),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Thấp'),
                selected: _priority == 0,
                onSelected: (s) => setState(() => _priority = 0),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Vừa'),
                selected: _priority == 1,
                onSelected: (s) => setState(() => _priority = 1),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Cao'),
                selected: _priority == 2,
                onSelected: (s) => setState(() => _priority = 2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.alarm),
            title: Text(_reminderDate == null
                ? 'Đặt nhắc nhở'
                : DateFormat('HH:mm, dd/MM/yyyy').format(_reminderDate!)),
            trailing: _reminderDate != null
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _reminderDate = null),
                  )
                : null,
            onTap: _selectReminder,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveTask,
            child: const Text('LƯU CÔNG VIỆC'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _selectReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _reminderDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (_titleController.text.isEmpty) return;

    final id = await ref.read(todoRepositoryProvider).addTask(
          TasksCompanion(
            title: drift.Value(_titleController.text),
            description: drift.Value(_descController.text),
            priority: drift.Value(_priority),
            reminderAt: drift.Value(_reminderDate),
          ),
        );

    if (_reminderDate != null && _reminderDate!.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: id,
        title: '⏰ Nhắc nhở công việc',
        body: _titleController.text,
        scheduledDate: _reminderDate!,
        payload: _titleController.text,
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
