import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/data/repositories/academic_repository_impl.dart';
import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/domain/entities/semester.dart';
import 'package:katyusha/domain/repositories/academic_repository.dart';
import 'package:katyusha/domain/usecases/academic/calculate_cgpa.dart';
import 'package:katyusha/injection_container.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';

final academicRepositoryProvider = Provider(
  (ref) => sl<AcademicRepositoryImpl>(),
);
final calculateCGPAProvider = Provider((ref) => CalculateCGPA());

final allSemestersProvider = FutureProvider<List<Semester>>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user != null) {
    return await ref
        .watch(academicRepositoryProvider)
        .getAcademicHistory(user.id!);
  }
  return [];
});

class SemesterManager {
  final Ref ref;
  final AcademicRepository _repository;

  SemesterManager(this.ref)
    : _repository = ref.watch(academicRepositoryProvider);

  Semester? get selectedSemester => ref.watch(selectedSemesterProvider);

  void setSelectedSemester(Semester? semester) {
    ref.read(selectedSemesterProvider.notifier).state = semester;
  }

  Future<void> addCourse(Semester semester, Course course) async {
    final existingSemesters = await _repository.getAcademicHistory(
      semester.userId,
    );
    final existingSemester = existingSemesters.firstWhere(
      (s) =>
          s.year == semester.year &&
          s.semesterNumber == semester.semesterNumber,
      orElse: () => semester.copyWith(courses: []),
    );
    final updatedCourses = [...existingSemester.courses, course];
    await _repository.saveSemester(
      existingSemester.copyWith(courses: updatedCourses),
    );
    // Refresh semesters and sync immediately
    final refreshedSemesters = await ref.refresh(allSemestersProvider.future);
    final updatedSemester = refreshedSemesters.firstWhere(
      (s) =>
          s.year == semester.year &&
          s.semesterNumber == semester.semesterNumber,
      orElse: () => existingSemester.copyWith(courses: updatedCourses),
    );
    setSelectedSemester(updatedSemester);
  }

  Future<void> updateCourse(
    Semester semester,
    int index,
    Course updatedCourse,
  ) async {
    final existingSemesters = await _repository.getAcademicHistory(
      semester.userId,
    );
    final existingSemester = existingSemesters.firstWhere(
      (s) =>
          s.year == semester.year &&
          s.semesterNumber == semester.semesterNumber,
      orElse: () => semester,
    );
    if (index >= 0 && index < existingSemester.courses.length) {
      final updatedCourses = List<Course>.from(existingSemester.courses)
        ..[index] = updatedCourse;
      await _repository.saveSemester(
        existingSemester.copyWith(courses: updatedCourses),
      );
      // Refresh semesters and sync immediately
      final refreshedSemesters = await ref.refresh(allSemestersProvider.future);
      final updatedSemester = refreshedSemesters.firstWhere(
        (s) =>
            s.year == semester.year &&
            s.semesterNumber == semester.semesterNumber,
        orElse: () => existingSemester.copyWith(courses: updatedCourses),
      );
      if (selectedSemester == existingSemester) {
        setSelectedSemester(updatedSemester);
      }
    }
  }

  Future<void> deleteCourse(Semester semester, int index) async {
    final existingSemesters = await _repository.getAcademicHistory(
      semester.userId,
    );
    final existingSemester = existingSemesters.firstWhere(
      (s) =>
          s.year == semester.year &&
          s.semesterNumber == semester.semesterNumber,
      orElse: () => semester,
    );
    if (index >= 0 && index < existingSemester.courses.length) {
      final updatedCourses = List<Course>.from(existingSemester.courses)
        ..removeAt(index);
      await _repository.saveSemester(
        existingSemester.copyWith(courses: updatedCourses),
      );
      // Refresh semesters and sync immediately
      final refreshedSemesters = await ref.refresh(allSemestersProvider.future);
      final updatedSemester = refreshedSemesters.firstWhere(
        (s) =>
            s.year == semester.year &&
            s.semesterNumber == semester.semesterNumber,
        orElse: () => existingSemester.copyWith(courses: updatedCourses),
      );
      if (selectedSemester == existingSemester) {
        setSelectedSemester(updatedSemester);
      }
    }
  }

  void _refreshSemesters() {
    ref.invalidate(allSemestersProvider); // Fallback refresh if needed
  }

  // Set initial semester on app start (e.g., most recent semester)
  Future<void> initialize() async {
    final semesters = await ref.read(allSemestersProvider.future);
    if (semesters.isNotEmpty) {
      final latestSemester = semesters.reduce((a, b) {
        final aDate = a.year * 12 + a.semesterNumber;
        final bDate = b.year * 12 + b.semesterNumber;
        return aDate > bDate ? a : b;
      });
      setSelectedSemester(latestSemester);
    }
  }
}

final semesterManagerProvider = Provider((ref) => SemesterManager(ref));
final selectedSemesterProvider = StateProvider<Semester?>((ref) => null);

final cgpaProvider = Provider.family<double, Semester?>((ref, semester) {
  final calculateCGPA = ref.watch(calculateCGPAProvider);
  return semester != null ? calculateCGPA(semester.courses) : 0.0;
});
