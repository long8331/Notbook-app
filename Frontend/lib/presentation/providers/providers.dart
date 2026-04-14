import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/data/repositories/repository_impl.dart';
import 'package:todo_list_app/domain/repositories/todo_repository.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Repository Providers
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TodoRepositoryImpl(db);
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NoteRepositoryImpl(db);
});

// State Providers (Stream)
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  return ref.watch(todoRepositoryProvider).watchAllTasks();
});

final notesStreamProvider = StreamProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAllNotes();
});

// Category Provider
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(todoRepositoryProvider).getAllCategories();
});
