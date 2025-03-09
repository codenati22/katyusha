import 'package:katyusha/domain/entities/semester.dart';

abstract class AcademicRepository {
  Future<List<Semester>> getAcademicHistory(int userId);
  Future<void> saveSemester(Semester semester);
}
