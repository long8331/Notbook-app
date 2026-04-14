import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';
import 'package:todo_list_app/presentation/widgets/empty_state.dart';
import 'package:todo_list_app/presentation/widgets/task_item.dart';
import 'package:todo_list_app/presentation/widgets/add_task_sheet.dart';

/// Các kiểu filter
enum TaskFilter { all, todo, done }

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen> {
  TaskFilter _filter = TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filter != TaskFilter.all,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chip filter bar
          if (_filter != TaskFilter.all)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    _filter == TaskFilter.todo ? 'Chưa hoàn thành' : 'Đã hoàn thành',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => setState(() => _filter = TaskFilter.all),
                    child: Icon(Icons.close, size: 16, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                // Áp filter
                final filtered = switch (_filter) {
                  TaskFilter.all  => tasks,
                  TaskFilter.todo => tasks.where((t) => !t.isCompleted).toList(),
                  TaskFilter.done => tasks.where((t) => t.isCompleted).toList(),
                };

                if (filtered.isEmpty) {
                  return EmptyState(
                    title: _filter == TaskFilter.all
                        ? 'Chưa có công việc nào'
                        : 'Không có công việc nào phù hợp',
                    subtitle: _filter == TaskFilter.all
                        ? 'Hãy nhấn nút + để thêm công việc mới.'
                        : 'Thử đổi bộ lọc khác.',
                    icon: _filter == TaskFilter.done
                        ? Icons.check_circle_outline
                        : Icons.checklist,
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return TaskItem(task: filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lọc công việc', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _filterTile(ctx, TaskFilter.all, Icons.list_alt, 'Tất cả'),
            _filterTile(ctx, TaskFilter.todo, Icons.radio_button_unchecked, 'Chưa hoàn thành'),
            _filterTile(ctx, TaskFilter.done, Icons.check_circle_outline, 'Đã hoàn thành'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _filterTile(BuildContext ctx, TaskFilter filter, IconData icon, String label) {
    final selected = _filter == filter;
    return ListTile(
      leading: Icon(icon, color: selected ? Theme.of(ctx).colorScheme.primary : null),
      title: Text(label),
      trailing: selected ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      tileColor: selected ? Theme.of(ctx).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      onTap: () {
        setState(() => _filter = filter);
        Navigator.pop(ctx);
      },
    );
  }
}
