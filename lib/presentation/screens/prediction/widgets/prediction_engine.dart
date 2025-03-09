import 'dart:async';
import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/domain/usecases/academic/calculate_cgpa.dart';

class PredictionEngine {
  final List<Course> currentCourses;
  final List<Course> _predictedCourses = [];
  final CalculateCGPA _calculateCGPA = CalculateCGPA();
  final _predictionStreamController =
      StreamController<PredictionResult>.broadcast();

  PredictionEngine({required this.currentCourses}) {
    _updatePrediction();
  }

  Stream<PredictionResult> get predictionStream =>
      _predictionStreamController.stream;

  void addPredictedCourse(Course course) {
    _predictedCourses.add(course);
    _updatePrediction();
  }

  void removePredictedCourse(int index) {
    if (index >= 0 && index < _predictedCourses.length) {
      _predictedCourses.removeAt(index);
      _updatePrediction();
    }
  }

  List<Course> get predictedCourses => List.unmodifiable(_predictedCourses);

  void _updatePrediction() {
    final currentCGPA =
        currentCourses.isNotEmpty ? _calculateCGPA(currentCourses) : 0.0;
    final allCourses = [...currentCourses, ..._predictedCourses];
    final predictedCGPA =
        allCourses.isNotEmpty ? _calculateCGPA(allCourses) : currentCGPA;
    final cgpaImpact = predictedCGPA - currentCGPA;

    _predictionStreamController.add(
      PredictionResult(
        currentCGPA: currentCGPA,
        predictedCGPA: predictedCGPA,
        cgpaImpact: cgpaImpact,
        totalCreditHours: currentCourses.fold(
          0.0,
          (sum, c) => sum + c.creditHours,
        ),
      ),
    );
  }

  void dispose() {
    _predictionStreamController.close();
  }
}

class PredictionResult {
  final double currentCGPA;
  final double predictedCGPA;
  final double cgpaImpact;
  final double totalCreditHours;

  PredictionResult({
    required this.currentCGPA,
    required this.predictedCGPA,
    required this.cgpaImpact,
    required this.totalCreditHours,
  });
}
