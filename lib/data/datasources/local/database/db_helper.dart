import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'tables/user_table.dart';
import 'tables/semesters_table.dart';
import 'tables/courses_table.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'katyusha.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(UserTable.createTable);
        await db.execute(SemestersTable.createTable);
        await db.execute(CoursesTable.createTable);
      },
    );
  }
}
