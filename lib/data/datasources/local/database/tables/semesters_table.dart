import 'package:katyusha/domain/entities/semester.dart';

class SemestersTable {
  static const String tableName = 'semesters';
  static const String createTable = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      year INTEGER NOT NULL,
      semester_number INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id)
    )
  ''';
  static Map<String, dynamic> toMap(Semester semester) {
    return {
      'id': semester.id,
      'user_id': semester.userId,
      'year': semester.year,
      'semester_number': semester.semesterNumber,
    };
  }
}
