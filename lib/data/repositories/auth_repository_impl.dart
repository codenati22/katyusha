import 'package:katyusha/core/exceptions/app_exception.dart';
import 'package:katyusha/data/datasources/local/database/db_helper.dart';
import 'package:katyusha/data/datasources/local/database/tables/user_table.dart';
import 'package:katyusha/domain/entities/user.dart';
import 'package:katyusha/domain/repositories/auth_repository.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DBHelper dbHelper;

  AuthRepositoryImpl(this.dbHelper);

  @override
  Future<User?> login(String username, String password) async {
    final db = await dbHelper.database;
    final result = await db.query(
      UserTable.tableName,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isEmpty) return null;
    final map = result.first;
    return User(
      id: map['id'] as int,
      fullName: map['full_name'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      department: map['department'] as String,
      programDuration: map['program_duration'] as int,
      initialCgpa: map['initial_cgpa'] as double,
    );
  }

  @override
  Future<User> signup(User user) async {
    final db = await dbHelper.database;
    try {
      final id = await db.insert(
        UserTable.tableName,
        UserTable.toMap({
          'full_name': user.fullName,
          'username': user.username,
          'password': user.password,
          'department': user.department,
          'program_duration': user.programDuration,
          'initial_cgpa': user.initialCgpa,
        }),
        conflictAlgorithm:
            ConflictAlgorithm.rollback, // Ensure rollback on conflict
      );
      return User(
        id: id,
        fullName: user.fullName,
        username: user.username,
        password: user.password,
        department: user.department,
        programDuration: user.programDuration,
        initialCgpa: user.initialCgpa,
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw DuplicateUsernameException();
      }
      throw AppException('Failed to sign up: ${e.toString()}');
    }
  }
}
