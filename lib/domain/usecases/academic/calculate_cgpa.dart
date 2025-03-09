import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/domain/entities/semester.dart';

class CalculateCGPA {
  static const gradeScale = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.75,
    'B+': 3.5,
    'B': 3.0,
    'B-': 2.75,
    'C+': 2.5,
    'C': 2.0,
    'C-': 1.75,
    'D': 1.0,
    'F': 0.0,
  };

  double call(List<Course> courses) {
    if (courses.isEmpty) return 0.0;

    double totalQualityPoints = 0.0;
    double totalCreditHours = 0.0;

    for (var course in courses) {
      final gradePoint = gradeScale[course.grade.toUpperCase()] ?? 0.0;
      totalQualityPoints += gradePoint * course.creditHours;
      totalCreditHours += course.creditHours;
    }

    return totalCreditHours > 0 ? totalQualityPoints / totalCreditHours : 0.0;
  }

  double calculateCumulative(List<Semester> semesters) {
    final allCourses = semesters.expand((s) => s.courses).toList();
    return call(allCourses);
  }

  double calculateQualityPoints(List<Course> courses) {
    double totalQualityPoints = 0.0;
    for (var course in courses) {
      final gradePoint = gradeScale[course.grade.toUpperCase()] ?? 0.0;
      totalQualityPoints += gradePoint * course.creditHours;
    }
    return totalQualityPoints;
  }

  double calculateCreditHours(List<Course> courses) {
    double totalCreditHours = 0.0;
    for (var course in courses) {
      totalCreditHours += course.creditHours;
    }
    return totalCreditHours;
  }
}
