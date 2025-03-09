class SemesterModel {
  final int? id;
  final int userId;
  final int year;
  final int semesterNumber;

  SemesterModel({
    this.id,
    required this.userId,
    required this.year,
    required this.semesterNumber,
  });
}
