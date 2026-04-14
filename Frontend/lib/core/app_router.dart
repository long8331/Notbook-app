import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_list_app/presentation/screens/main_shell.dart';
import 'package:todo_list_app/presentation/screens/todo_screen.dart';
import 'package:todo_list_app/presentation/screens/note_screen.dart';
import 'package:todo_list_app/presentation/screens/calendar_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/tasks',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TodoScreen(),
        ),
        GoRoute(
          path: '/notes',
          builder: (context, state) => const NoteScreen(),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
      ],
    ),
  ],
);
