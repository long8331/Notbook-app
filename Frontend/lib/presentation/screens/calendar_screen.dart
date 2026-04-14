import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_list_app/presentation/providers/providers.dart';
import 'package:todo_list_app/presentation/widgets/task_item.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch công việc'),
      ),
      body: Column(
        children: [
          tasksAsync.when(
            data: (tasks) => TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return tasks.where((task) {
                  if (task.reminderAt == null) return false;
                  return isSameDay(task.reminderAt, day);
                }).toList();
              },
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const Divider(),
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final dayTasks = tasks.where((task) {
                  if (task.reminderAt == null) return false;
                  return isSameDay(task.reminderAt, _selectedDay);
                }).toList();

                if (dayTasks.isEmpty) {
                  return const Center(child: Text('Không có công việc nào trong ngày này.'));
                }

                return ListView.builder(
                  itemCount: dayTasks.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return TaskItem(task: dayTasks[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => Center(child: Text('Lỗi: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
