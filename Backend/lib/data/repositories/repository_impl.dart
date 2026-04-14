import 'package:drift/drift.dart';
import 'package:todo_list_app/data/datasources/app_database.dart';
import 'package:todo_list_app/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase _db;

  TodoRepositoryImpl(this._db);

  @override
  Future<List<Task>> getAllTasks() => _db.select(_db.tasks).get();

  @override
  Stream<List<Task>> watchAllTasks() => _db.select(_db.tasks).watch();

  @override
  Future<int> addTask(TasksCompanion task) => _db.into(_db.tasks).insert(task);

  @override
  Future<bool> updateTask(Task task) => _db.update(_db.tasks).replace(task);

  @override
  Future<int> deleteTask(int id) => (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<Category>> getAllCategories() => _db.select(_db.categories).get();

  @override
  Future<int> addCategory(CategoriesCompanion category) => _db.into(_db.categories).insert(category);
}

class NoteRepositoryImpl implements NoteRepository {
  final AppDatabase _db;

  NoteRepositoryImpl(this._db);

  @override
  Future<List<Note>> getAllNotes() => (_db.select(_db.notes)..orderBy([(t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc)])).get();

  @override
  Stream<List<Note>> watchAllNotes() => (_db.select(_db.notes)..orderBy([(t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc)])).watch();

  @override
  Future<int> addNote(NotesCompanion note) => _db.into(_db.notes).insert(note);

  @override
  Future<bool> updateNote(Note note) => _db.update(_db.notes).replace(note);

  @override
  Future<int> deleteNote(int id) => (_db.delete(_db.notes)..where((t) => t.id.equals(id))).go();
}
