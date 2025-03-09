import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/presentation/providers/academic_provider.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:katyusha/presentation/screens/prediction/widgets/prediction_engine.dart';

class PredictionScreen extends ConsumerStatefulWidget {
  const PredictionScreen({super.key});

  @override
  ConsumerState<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends ConsumerState<PredictionScreen> {
  int predictedYear = DateTime.now().year + 1; // Default to next year
  int predictedSemesterNumber = 1; // Default to Semester 1
  late PredictionEngine _predictionEngine;
  StreamSubscription<PredictionResult>? _predictionSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize with an empty list initially, will update in build
    _predictionEngine = PredictionEngine(currentCourses: []);
    _setupPredictionStream();
  }

  void _setupPredictionStream() {
    _predictionSubscription?.cancel();
    _predictionSubscription = _predictionEngine.predictionStream.listen(
      (predictionResult) {
        print(
          'Stream updated: Predicted CGPA: ${predictionResult.predictedCGPA}, Impact: ${predictionResult.cgpaImpact}',
        );
      },
      onError: (error) {
        print('Stream error: $error');
      },
    );
  }

  @override
  void dispose() {
    _predictionSubscription?.cancel();
    _predictionEngine.dispose();
    super.dispose();
  }

  void _showAddPredictedCourseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final creditController = TextEditingController();
    String selectedGrade = 'A';

    showCupertinoDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Add Predicted Course'),
                content: SingleChildScrollView(
                  child: CupertinoFormSection.insetGrouped(
                    header: const Text('Course Details'),
                    children: [
                      CupertinoTextFormFieldRow(
                        placeholder: 'Course Name',
                        controller: nameController,
                      ),
                      CupertinoTextFormFieldRow(
                        placeholder: 'Credit Hours',
                        controller: creditController,
                        keyboardType: TextInputType.number,
                      ),
                      Row(
                        children: [
                          const Text('Grade:'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(8),
                              child: Text(
                                selectedGrade,
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () async {
                                final picked =
                                    await showCupertinoModalPopup<String>(
                                      context: context,
                                      builder:
                                          (context) => SizedBox(
                                            height: 200,
                                            child: CupertinoPicker(
                                              itemExtent: 32,
                                              children: const [
                                                Text('A+'),
                                                Text('A'),
                                                Text('A-'),
                                                Text('B+'),
                                                Text('B'),
                                                Text('B-'),
                                                Text('C+'),
                                                Text('C'),
                                                Text('C-'),
                                                Text('D'),
                                                Text('F'),
                                              ],
                                              onSelectedItemChanged: (value) {
                                                setState(() {
                                                  selectedGrade =
                                                      [
                                                        'A+',
                                                        'A',
                                                        'A-',
                                                        'B+',
                                                        'B',
                                                        'B-',
                                                        'C+',
                                                        'C',
                                                        'C-',
                                                        'D',
                                                        'F',
                                                      ][value];
                                                });
                                              },
                                            ),
                                          ),
                                    );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Add'),
                    onPressed: () {
                      final course = Course(
                        name:
                            nameController.text.isEmpty
                                ? 'Unnamed'
                                : nameController.text,
                        creditHours:
                            double.tryParse(creditController.text) ?? 3.0,
                        grade: selectedGrade,
                      );
                      _predictionEngine.addPredictedCourse(course);
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showSelectSemesterDialog(BuildContext context) {
    final user = ref.read(authStateProvider);
    final maxSemesters =
        (user?.programDuration ?? 4) * 3; // 3 semesters per year
    int year = predictedYear;
    int semesterNumber = predictedSemesterNumber;

    showCupertinoDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Select Predicted Semester'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('Year:'),
                        const SizedBox(width: 10),
                        CupertinoButton(
                          child: Text('$year'),
                          onPressed: () async {
                            final picked = await showCupertinoModalPopup<int>(
                              context: context,
                              builder:
                                  (context) => SizedBox(
                                    height: 200,
                                    child: CupertinoPicker(
                                      itemExtent: 32,
                                      children: List.generate(
                                        10,
                                        (index) => Text(
                                          '${DateTime.now().year + index}',
                                        ),
                                      ),
                                      onSelectedItemChanged: (value) {
                                        setState(() {
                                          year = DateTime.now().year + value;
                                        });
                                      },
                                    ),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Semester:'),
                        const SizedBox(width: 10),
                        CupertinoButton(
                          child: Text('$semesterNumber'),
                          onPressed: () async {
                            final picked = await showCupertinoModalPopup<int>(
                              context: context,
                              builder:
                                  (context) => SizedBox(
                                    height: 200,
                                    child: CupertinoPicker(
                                      itemExtent: 32,
                                      children: List.generate(
                                        maxSemesters,
                                        (index) => Text('${index + 1}'),
                                      ),
                                      onSelectedItemChanged: (value) {
                                        setState(() {
                                          semesterNumber = value + 1;
                                        });
                                      },
                                    ),
                                  ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Confirm'),
                    onPressed: () {
                      setState(() {
                        predictedYear = year;
                        predictedSemesterNumber = semesterNumber;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  double _calculateCGPA(List<Course> courses) {
    if (courses.isEmpty) return 0.0;
    double totalPoints = 0.0;
    double totalCredits = 0.0;
    for (var course in courses) {
      totalPoints += course.creditHours * _gradeToPoint(course.grade);
      totalCredits += course.creditHours;
    }
    return totalPoints / totalCredits;
  }

  double _gradeToPoint(String grade) {
    switch (grade) {
      case 'A+':
        return 4.0;
      case 'A':
        return 4.0;
      case 'A-':
        return 3.75;
      case 'B+':
        return 3.5;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.75;
      case 'C+':
        return 2.5;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.75;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(allSemestersProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('CGPA Prediction'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.gear),
          onPressed: () => _showSelectSemesterDialog(context),
        ),
      ),
      child: SafeArea(
        child: semestersAsync.when(
          data: (semesters) {
            final currentCourses = semesters.expand((s) => s.courses).toList();

            // Reinitialize PredictionEngine if currentCourses changes
            if (_predictionEngine.currentCourses != currentCourses) {
              _predictionEngine.dispose(); // Dispose of the old engine
              _predictionEngine = PredictionEngine(
                currentCourses: currentCourses,
              );
              _setupPredictionStream(); // Re-subscribe to the new stream
              print(
                'PredictionEngine reinitialized with ${currentCourses.length} current courses',
              );
            }

            return StreamBuilder<PredictionResult>(
              stream: _predictionEngine.predictionStream,
              initialData: PredictionResult(
                currentCGPA:
                    currentCourses.isNotEmpty
                        ? _calculateCGPA(currentCourses)
                        : 0.0,
                predictedCGPA:
                    currentCourses.isNotEmpty
                        ? _calculateCGPA(currentCourses)
                        : 0.0,
                cgpaImpact: 0.0,
                totalCreditHours: currentCourses.fold(
                  0.0,
                  (sum, c) => sum + c.creditHours,
                ),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                final predictionResult = snapshot.data!;
                final predictedCourses = _predictionEngine.predictedCourses;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Academic Status
                      const Text(
                        'Current Academic Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoFormSection.insetGrouped(
                        children: [
                          CupertinoFormRow(
                            prefix: const Text('Current CGPA'),
                            child: Text(
                              predictionResult.currentCGPA.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text('Total Credit Hours'),
                            child: Text(
                              predictionResult.totalCreditHours.toStringAsFixed(
                                2,
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Prediction Input
                      const Text(
                        'Predicted Semester',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoFormRow(
                        prefix: const Text('Year & Semester'),
                        child: Text(
                          'Year $predictedYear, Semester $predictedSemesterNumber',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoButton.filled(
                        child: const Text('Add Predicted Course'),
                        onPressed: () => _showAddPredictedCourseDialog(context),
                      ),
                      const SizedBox(height: 16),

                      // Predicted Courses List
                      if (predictedCourses.isNotEmpty)
                        CupertinoListSection.insetGrouped(
                          header: const Text('Predicted Courses'),
                          children:
                              predictedCourses.asMap().entries.map((entry) {
                                final index = entry.key;
                                final course = entry.value;
                                return CupertinoListTile(
                                  title: Text(course.name),
                                  subtitle: Text(
                                    'Credits: ${course.creditHours} | Grade: ${course.grade}',
                                  ),
                                  trailing: CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    child: const Icon(
                                      CupertinoIcons.delete,
                                      color: CupertinoColors.destructiveRed,
                                    ),
                                    onPressed: () {
                                      _predictionEngine.removePredictedCourse(
                                        index,
                                      );
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                      const SizedBox(height: 16),

                      // Predicted Results
                      const Text(
                        'Predicted Results',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CupertinoFormSection.insetGrouped(
                        children: [
                          CupertinoFormRow(
                            prefix: const Text('Predicted CGPA'),
                            child: Text(
                              predictionResult.predictedCGPA.toStringAsFixed(2),
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                          CupertinoFormRow(
                            prefix: const Text('Impact'),
                            child: Text(
                              '${predictionResult.cgpaImpact >= 0 ? '+' : ''}${predictionResult.cgpaImpact.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    predictionResult.cgpaImpact >= 0
                                        ? CupertinoColors.activeGreen
                                        : CupertinoColors.destructiveRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, stack) {
            print('Error loading semesters: $error');
            return const Center(child: Text('Error loading academic history'));
          },
        ),
      ),
    );
  }
}
