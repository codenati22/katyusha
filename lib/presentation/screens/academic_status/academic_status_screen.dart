import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/presentation/providers/academic_provider.dart';
import 'package:katyusha/presentation/screens/academic_status/widgets/semester_list.dart';

class AcademicStatusScreen extends ConsumerWidget {
  const AcademicStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semesters = ref.watch(allSemestersProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Academic Status'),
      ),
      child: SafeArea(
        child: semesters.when(
          data: (semesters) {
            if (semesters.isEmpty) {
              return const Center(child: Text('No academic history available'));
            }
            final calculateCGPA = ref.watch(calculateCGPAProvider);
            final cumulativeCGPA = calculateCGPA.calculateCumulative(semesters);
            final totalQualityPoints = semesters.fold<double>(
              0,
              (sum, s) => sum + calculateCGPA.calculateQualityPoints(s.courses),
            );
            final totalCreditHours = semesters.fold<double>(
              0,
              (sum, s) => sum + calculateCGPA.calculateCreditHours(s.courses),
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Cumulative CGPA: ${cumulativeCGPA.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Quality Points: ${totalQualityPoints.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Credit Hours: ${totalCreditHours.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SemesterList(semesters: semesters),
                ],
              ),
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error:
              (error, stack) =>
                  const Center(child: Text('No user data available')),
        ),
      ),
    );
  }
}
