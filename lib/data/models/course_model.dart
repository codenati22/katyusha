class CourseModel {
  final int? id;
  final int semesterId;
  final String name;
  final double creditHours;
  final String grade;

  CourseModel({
    this.id,
    required this.semesterId,
    required this.name,
    required this.creditHours,
    required this.grade,
  });
}
