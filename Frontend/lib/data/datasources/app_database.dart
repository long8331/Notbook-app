import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Bảng danh mục
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
}

// Bảng công việc (Tasks)
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 0: Low, 1: Medium, 2: High
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get reminderAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Bảng ghi chú (Notes)
class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get content => text()(); // Lưu dưới dạng JSON của Quill
  IntColumn get color => integer().withDefault(const Constant(0xFFFFFFFF))(); // Màu trắng mặc định
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Categories, Tasks, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Lấy danh sách task kèm category
  // Sẽ thêm các query custom sau này
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'todo_notes.db'));
    return NativeDatabase(file);
  });
}
