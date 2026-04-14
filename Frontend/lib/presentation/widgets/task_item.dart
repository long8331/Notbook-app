import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';

class TaskItem extends ConsumerWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('task_${task.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        ref.read(todoRepositoryProvider).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa công việc')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) {
              ref.read(todoRepositoryProvider).updateTask(
                    task.copyWith(isCompleted: value ?? false),
                  );
            },
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? colorScheme.onSurfaceVariant : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty)
                Text(task.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (task.reminderAt != null)
                Row(
                  children: [
                    Icon(Icons.alarm, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('HH:mm, dd/MM/yyyy').format(task.reminderAt!),
                      style: TextStyle(fontSize: 12, color: colorScheme.primary),
                    ),
                  ],
                ),
            ],
          ),
          trailing: _PriorityBadge(priority: task.priority),
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case 2:
        color = Colors.red;
        label = 'Cao';
        break;
      case 1:
        color = Colors.orange;
        label = 'Trung bình';
        break;
      default:
        color = Colors.green;
        label = 'Thấp';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
