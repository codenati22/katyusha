import 'package:katyusha/data/datasources/local/database/db_helper.dart';
import 'package:katyusha/data/datasources/local/database/tables/courses_table.dart';
import 'package:katyusha/data/datasources/local/database/tables/semesters_table.dart';
import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/domain/entities/semester.dart';
import 'package:katyusha/domain/repositories/academic_repository.dart';
import 'package:katyusha/core/utils/logger.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final DBHelper dbHelper;

  AcademicRepositoryImpl(this.dbHelper);

  @override
  Future<List<Semester>> getAcademicHistory(int userId) async {
    final db = await dbHelper.database;
    final semesterMaps = await db.query(
      SemestersTable.tableName,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'year, semester_number', // Ensure chronological order
    );

    final semesters = <Semester>[];
    for (final map in semesterMaps) {
      final semesterId = map['id'] as int;
      final courseMaps = await db.query(
        CoursesTable.tableName,
        where: 'semester_id = ?',
        whereArgs: [semesterId],
      );
      final courses =
          courseMaps
              .map(
                (c) => Course(
                  name: c['name'] as String,
                  creditHours: c['credit_hours'] as double,
                  grade: c['grade'] as String,
                ),
              )
              .toList();
      semesters.add(
        Semester(
          id: semesterId,
          userId: map['user_id'] as int,
          year: map['year'] as int,
          semesterNumber: map['semester_number'] as int,
          courses: courses,
        ),
      );
      Logger.log(
        'Retrieved semester: Year ${map['year']} Semester ${map['semester_number']} with ${courses.length} courses',
      );
    }
    return semesters;
  }

  @override
  Future<void> saveSemester(Semester semester) async {
    final db = await dbHelper.database;
    final semesterMap = SemestersTable.toMap(semester);

    // Check if semester already exists for this user, year, and semesterNumber
    final existingSemester = await db.query(
      SemestersTable.tableName,
      where: 'user_id = ? AND year = ? AND semester_number = ?',
      whereArgs: [semester.userId, semester.year, semester.semesterNumber],
      limit: 1,
    );

    if (existingSemester.isEmpty) {
      // Insert new semester
      final semesterId = await db.insert(SemestersTable.tableName, semesterMap);
      for (final course in semester.courses) {
        await db.insert(
          CoursesTable.tableName,
          CoursesTable.toMap(course, semesterId),
        );
      }
      Logger.log(
        'Inserted new semester: Year ${semester.year} Semester ${semester.semesterNumber} with ID $semesterId',
      );
    } else {
      // Update existing semester
      final semesterId = existingSemester.first['id'] as int;
      await db.update(
        SemestersTable.tableName,
        {
          'user_id': semester.userId,
          'year': semester.year,
          'semester_number': semester.semesterNumber,
        },
        where: 'id = ?',
        whereArgs: [semesterId],
      );
      // Delete old courses and insert new ones
      await db.delete(
        CoursesTable.tableName,
        where: 'semester_id = ?',
        whereArgs: [semesterId],
      );
      for (final course in semester.courses) {
        await db.insert(
          CoursesTable.tableName,
          CoursesTable.toMap(course, semesterId),
        );
      }
      Logger.log(
        'Updated semester: Year ${semester.year} Semester ${semester.semesterNumber} with ID $semesterId',
      );
    }
  }
}
