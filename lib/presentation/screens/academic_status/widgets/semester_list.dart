import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/domain/entities/semester.dart';
import 'package:katyusha/presentation/providers/academic_provider.dart';

class SemesterList extends ConsumerWidget {
  final List<Semester> semesters;

  const SemesterList({super.key, required this.semesters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculateCGPA = ref.watch(calculateCGPAProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: semesters.length,
      itemBuilder: (context, index) {
        final semester = semesters[index];
        final gpa = calculateCGPA(semester.courses);

        return _SemesterCard(semester: semester, gpa: gpa);
      },
    );
  }
}

class _SemesterCard extends StatefulWidget {
  final Semester semester;
  final double gpa;

  const _SemesterCard({required this.semester, required this.gpa});

  @override
  __SemesterCardState createState() => __SemesterCardState();
}

class __SemesterCardState extends State<_SemesterCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _heightFactorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _heightFactorAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semester = widget.semester;
    final gpa = widget.gpa;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
            if (_isExpanded) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          });
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 2.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Year ${semester.year} - Semester ${semester.semesterNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Icon(
                            _isExpanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            color: CupertinoColors.activeBlue,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                              if (_isExpanded) {
                                _controller.forward();
                              } else {
                                _controller.reverse();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  ClipRect(
                    child: Align(
                      heightFactor: _heightFactorAnimation.value,
                      child: Opacity(
                        opacity: _opacityAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(
                            16.0,
                            0,
                            16.0,
                            16.0,
                          ),
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GPA: ${gpa.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...semester.courses.map<Widget>((course) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            course.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: CupertinoColors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${course.creditHours} hrs - ${course.grade}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: CupertinoColors.systemGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
