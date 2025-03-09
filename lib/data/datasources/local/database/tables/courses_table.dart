import 'package:katyusha/domain/entities/course.dart';

class CoursesTable {
  static const String tableName = 'courses';
  static const String createTable = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      semester_id INTEGER NOT NULL,
      name TEXT NOT NULL,
      credit_hours REAL NOT NULL,
      grade TEXT NOT NULL,
      FOREIGN KEY (semester_id) REFERENCES semesters(id)
    )
  ''';
  static Map<String, dynamic> toMap(Course course, int semesterId) {
    return {
      'semester_id': semesterId,
      'name': course.name,
      'credit_hours': course.creditHours,
      'grade': course.grade,
    };
  }
}
