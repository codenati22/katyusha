import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/domain/entities/course.dart';
import 'package:katyusha/domain/entities/semester.dart';
import 'package:katyusha/presentation/providers/academic_provider.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:katyusha/presentation/screens/home/widgets/course_card.dart';
import 'package:katyusha/presentation/screens/home/widgets/gpa_chart.dart';
import 'package:katyusha/presentation/screens/home/widgets/semester_summary.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onDrawerToggle;

  const HomeScreen({super.key, required this.onDrawerToggle});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(semesterManagerProvider).initialize();
      _syncSelectedSemester();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncSelectedSemester() {
    final semesters = ref.read(allSemestersProvider).valueOrNull;
    if (semesters != null && semesters.isNotEmpty) {
      final sortedSemesters =
          semesters..sort(
            (a, b) => (b.year * 10 + b.semesterNumber).compareTo(
              a.year * 10 + a.semesterNumber,
            ),
          );
      final currentSemesters =
          sortedSemesters.skip(_currentPage * 3).take(3).toList();
      final selectedSemester = ref.read(selectedSemesterProvider);
      if (selectedSemester == null ||
          !currentSemesters.contains(selectedSemester)) {
        if (currentSemesters.isNotEmpty) {
          ref.read(selectedSemesterProvider.notifier).state =
              currentSemesters.first;
        }
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _syncSelectedSemester();
  }

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(allSemestersProvider);
    final selectedSemester = ref.watch(selectedSemesterProvider);
    final cgpa = ref.watch(cgpaProvider(selectedSemester));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Katyusha'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bars),
          onPressed: widget.onDrawerToggle,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _showAddCourseDialog(context, ref),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Semester selector with PageView
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60, // Fixed height for consistency
                child: semestersAsync.when(
                  data: (allSemesters) {
                    if (allSemesters.isEmpty) return const SizedBox.shrink();
                    final sortedSemesters =
                        allSemesters..sort(
                          (a, b) => (b.year * 10 + b.semesterNumber).compareTo(
                            a.year * 10 + a.semesterNumber,
                          ),
                        );
                    final pageCount = (sortedSemesters.length / 3).ceil();
                    return PageView.builder(
                      controller: _pageController,
                      itemCount: pageCount,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, pageIndex) {
                        final currentSemesters =
                            sortedSemesters
                                .skip(pageIndex * 3)
                                .take(3)
                                .toList();
                        final semesterOptions = <int, Widget>{};
                        for (final semester in currentSemesters) {
                          final index = currentSemesters.indexOf(semester);
                          semesterOptions[index] = Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              'Y${semester.year} S${semester.semesterNumber}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }
                        return Center(
                          child:
                              currentSemesters.length >= 2
                                  ? CupertinoSlidingSegmentedControl<int>(
                                    children: semesterOptions,
                                    groupValue:
                                        currentSemesters.contains(
                                              selectedSemester,
                                            )
                                            ? currentSemesters.indexOf(
                                              selectedSemester!,
                                            )
                                            : currentSemesters.isNotEmpty
                                            ? 0
                                            : null,
                                    onValueChanged: (int? index) {
                                      if (index != null &&
                                          currentSemesters.isNotEmpty) {
                                        ref
                                            .read(
                                              selectedSemesterProvider.notifier,
                                            )
                                            .state = currentSemesters[index];
                                      }
                                    },
                                    padding: const EdgeInsets.all(4),
                                  )
                                  : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Y${currentSemesters.first.year} S${currentSemesters.first.semesterNumber}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                        );
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CupertinoActivityIndicator()),
                  error:
                      (_, __) =>
                          const Center(child: Text('Error loading semesters')),
                ),
              ),
            ),
            // Dot indicator for pagination
            SliverToBoxAdapter(
              child: semestersAsync.when(
                data: (allSemesters) {
                  if (allSemesters.isEmpty) return const SizedBox.shrink();
                  final pageCount = (allSemesters.length / 3).ceil();
                  return pageCount > 1
                      ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pageCount, (index) {
                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                width: _currentPage == index ? 10.0 : 6.0,
                                height: _currentPage == index ? 10.0 : 6.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      _currentPage == index
                                          ? CupertinoColors.activeBlue
                                          : CupertinoColors.systemGrey,
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                      : const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(child: SemesterSummary(cgpa: cgpa)),
            SliverToBoxAdapter(
              child: GPAChart(courses: selectedSemester?.courses ?? []),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (selectedSemester == null ||
                      selectedSemester.courses.isEmpty) {
                    return const Center(child: Text('No courses added yet'));
                  }
                  final course = selectedSemester.courses[index];
                  return CourseCard(
                    course: course,
                    onEdit:
                        () => _showEditCourseDialog(
                          context,
                          ref,
                          index,
                          course,
                          selectedSemester,
                        ),
                    onDelete:
                        () => _showDeleteConfirmationDialog(
                          context,
                          ref,
                          index,
                          selectedSemester!,
                        ), // Updated to show confirmation dialog
                  );
                },
                childCount:
                    selectedSemester?.courses.length ??
                    (selectedSemester == null ? 1 : 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCourseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final creditController = TextEditingController();
    String selectedGrade = 'A'; // Default grade
    int year = DateTime.now().year;
    int semesterNumber = 1;
    final user = ref.read(authStateProvider);
    final maxSemesters =
        (user?.programDuration ?? 4) * 3; // 3 semesters per year
    final semesterManager = ref.read(semesterManagerProvider);

    showCupertinoDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Add Course'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoTextField(
                          controller: nameController,
                          placeholder: 'Course Name',
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: creditController,
                          placeholder: 'Credit Hours',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Grade:'),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              child: Text(selectedGrade),
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Year:'),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              child: Text('$year'),
                              onPressed: () async {
                                final picked = await showCupertinoModalPopup<
                                  int
                                >(
                                  context: context,
                                  builder:
                                      (context) => SizedBox(
                                        height: 200,
                                        child: CupertinoPicker(
                                          itemExtent: 32,
                                          children: List.generate(
                                            10,
                                            (index) => Text(
                                              '${DateTime.now().year - 5 + index}',
                                            ),
                                          ),
                                          onSelectedItemChanged: (value) {
                                            setState(() {
                                              year =
                                                  DateTime.now().year -
                                                  5 +
                                                  value;
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
                                final picked =
                                    await showCupertinoModalPopup<int>(
                                      context: context,
                                      builder:
                                          (context) => SizedBox(
                                            height: 200,
                                            child: CupertinoPicker(
                                              itemExtent: 32,
                                              children: List.generate(
                                                3, // Restrict to 3 semesters
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
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Add'),
                    onPressed: () async {
                      final course = Course(
                        name:
                            nameController.text.isEmpty
                                ? 'Unnamed'
                                : nameController.text,
                        creditHours:
                            double.tryParse(creditController.text) ?? 3.0,
                        grade: selectedGrade,
                      );
                      await semesterManager.addCourse(
                        Semester(
                          userId: user!.id!,
                          year: year,
                          semesterNumber: semesterNumber,
                          courses: [],
                        ),
                        course,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.refresh(allSemestersProvider);
                        _syncSelectedSemester();
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showEditCourseDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    Course course,
    Semester semester,
  ) {
    final nameController = TextEditingController(text: course.name);
    final creditController = TextEditingController(
      text: course.creditHours.toString(),
    );
    String selectedGrade = course.grade;

    showCupertinoDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return CupertinoAlertDialog(
                title: const Text('Edit Course'),
                content: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoTextField(
                          controller: nameController,
                          placeholder: 'Course Name',
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: creditController,
                          placeholder: 'Credit Hours',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Grade:'),
                            const SizedBox(width: 10),
                            CupertinoButton(
                              child: Text(selectedGrade),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoDialogAction(
                    child: const Text('Update'),
                    onPressed: () async {
                      final updatedCourse = Course(
                        name:
                            nameController.text.isEmpty
                                ? 'Unnamed'
                                : nameController.text,
                        creditHours:
                            double.tryParse(creditController.text) ??
                            course.creditHours,
                        grade: selectedGrade,
                      );
                      await ref
                          .read(semesterManagerProvider)
                          .updateCourse(semester, index, updatedCourse);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ref.refresh(allSemestersProvider);
                        _syncSelectedSemester();
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
    Semester semester,
  ) {
    showCupertinoDialog(
      context: context,
      builder:
          (context) => CupertinoAlertDialog(
            title: const Text('Delete Course'),
            content: const Text('Are you sure you want to delete this course?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoDialogAction(
                child: const Text('Delete'),
                isDestructiveAction: true,
                onPressed: () async {
                  await ref
                      .read(semesterManagerProvider)
                      .deleteCourse(semester, index);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ref.refresh(allSemestersProvider);
                    _syncSelectedSemester();
                  }
                },
              ),
            ],
          ),
    );
  }
}
