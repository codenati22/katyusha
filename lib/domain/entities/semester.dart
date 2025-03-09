import 'package:katyusha/domain/entities/course.dart';

class Semester {
  final int? id;
  final int userId; // Added userId
  final int year;
  final int semesterNumber;
  final List<Course> courses;

  Semester({
    this.id,
    required this.userId,
    required this.year,
    required this.semesterNumber,
    required this.courses,
  });

  Semester copyWith({
    int? id,
    int? userId,
    int? year,
    int? semesterNumber,
    List<Course>? courses,
  }) {
    return Semester(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      year: year ?? this.year,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      courses: courses ?? this.courses,
    );
  }
}
