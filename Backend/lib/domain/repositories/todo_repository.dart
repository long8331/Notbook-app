import 'package:todo_list_app/data/datasources/app_database.dart';

abstract class TodoRepository {
  Future<List<Task>> getAllTasks();
  Stream<List<Task>> watchAllTasks();
  Future<int> addTask(TasksCompanion task);
  Future<bool> updateTask(Task task);
  Future<int> deleteTask(int id);
  
  // Categories
  Future<List<Category>> getAllCategories();
  Future<int> addCategory(CategoriesCompanion category);
}

abstract class NoteRepository {
  Future<List<Note>> getAllNotes();
  Stream<List<Note>> watchAllNotes();
  Future<int> addNote(NotesCompanion note);
  Future<bool> updateNote(Note note);
  Future<int> deleteNote(int id);
}
