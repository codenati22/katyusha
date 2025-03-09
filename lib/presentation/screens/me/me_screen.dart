import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/presentation/providers/academic_provider.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:confetti/confetti.dart';
import 'package:katyusha/domain/entities/semester.dart';
import 'dart:math' as math;

class MeScreen extends ConsumerStatefulWidget {
  final VoidCallback onDrawerToggle;

  const MeScreen({super.key, required this.onDrawerToggle});

  @override
  ConsumerState<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends ConsumerState<MeScreen> {
  late ConfettiController _confettiController;
  bool _hasTriggeredEffect = false; // Flag to trigger effect only once
  bool _isHighCGPA = false; // Flag for CGPA > 3.7
  bool _isLowCGPA = false; // Flag for CGPA < 2.7

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _triggerEffect(double cgpa) {
    if (_hasTriggeredEffect) return; // Prevent multiple triggers

    if (cgpa > 3.7 && cgpa <= 4.0) {
      setState(() {
        _isHighCGPA = true;
        _isLowCGPA = false;
      });
      _confettiController.play(); // Trigger magnificent confetti
    } else if (cgpa < 2.7 && cgpa >= 0.0) {
      setState(() {
        _isHighCGPA = false;
        _isLowCGPA = true;
      });
      _showSadPopup(); // Show sad popup
    } else {
      setState(() {
        _isHighCGPA = false;
        _isLowCGPA = false;
      });
    }
    _hasTriggeredEffect = true; // Set flag after triggering
  }

  void _showSadPopup() {
    showCupertinoDialog(
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: const Row(
              children: [
                Text('😢 '), // Sad emoji
                Text('Attention'),
              ],
            ),
            content: const Text('You have to work hard!'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (math.pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * math.cos(step),
        halfWidth + externalRadius * math.sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * math.cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * math.sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final semestersFuture =
        user != null
            ? ref.watch(academicRepositoryProvider).getAcademicHistory(user.id!)
            : null;
    final calculateCGPA = ref.watch(calculateCGPAProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.bars),
          onPressed: widget.onDrawerToggle,
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Department: ${user?.department ?? "N/A"}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<List<Semester>>(
                      future: semestersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CupertinoActivityIndicator();
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text(
                            'No academic data available',
                            textAlign: TextAlign.center,
                          );
                        }
                        final allSemesters = snapshot.data!;
                        final cumulativeCGPA = calculateCGPA
                            .calculateCumulative(allSemesters)
                            .clamp(
                              0.0,
                              4.0,
                            ); // Ensure CGPA is within valid range

                        // Trigger effect after build using post-frame callback
                        if (!_hasTriggeredEffect) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _triggerEffect(cumulativeCGPA);
                          });
                        }

                        return Column(
                          children: [
                            // Cumulative CGPA Chart
                            SizedBox(
                              height: 200,
                              child: SfCircularChart(
                                title: ChartTitle(
                                  text: 'Cumulative CGPA',
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                legend: Legend(isVisible: false),
                                series: <CircularSeries>[
                                  DoughnutSeries<ChartData, String>(
                                    dataSource: [
                                      ChartData('CGPA', cumulativeCGPA),
                                      ChartData(
                                        'Remaining',
                                        4.0 - cumulativeCGPA,
                                      ),
                                    ],
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    pointColorMapper:
                                        (ChartData data, _) =>
                                            data.y == cumulativeCGPA
                                                ? CupertinoColors.activeBlue
                                                : CupertinoColors.systemGrey,
                                    radius: '80%',
                                    innerRadius: '60%',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Cumulative CGPA: ${cumulativeCGPA.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            // Academic Progress Chart
                            SizedBox(
                              height: 200,
                              child: SfCircularChart(
                                title: ChartTitle(
                                  text: 'Academic Progress',
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                legend: Legend(isVisible: false),
                                series: <CircularSeries>[
                                  DoughnutSeries<ChartData, String>(
                                    dataSource: [
                                      ChartData(
                                        'Completed',
                                        allSemesters.length.toDouble(),
                                      ),
                                      ChartData(
                                        'Remaining',
                                        (user?.programDuration ?? 4) * 3 -
                                            allSemesters.length.toDouble(),
                                      ),
                                    ],
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    pointColorMapper:
                                        (ChartData data, _) =>
                                            data.x == 'Completed'
                                                ? CupertinoColors.activeGreen
                                                : CupertinoColors.systemGrey,
                                    radius: '80%',
                                    innerRadius: '60%',
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(
                                        fontSize: 16,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${allSemesters.length} / ${(user?.programDuration ?? 4) * 3} semesters completed',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Magnificent confetti for CGPA > 3.7
            if (_isHighCGPA)
              Align(
                alignment: Alignment.center,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false, // One-time magnificent effect
                  colors: const [
                    Colors.green,
                    Colors.blue,
                    Colors.pink,
                    Colors.orange,
                    Colors.purple,
                  ],
                  createParticlePath: drawStar,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  maxBlastForce: 20,
                  minBlastForce: 5,
                  gravity: 0.2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Chart data model for Syncfusion charts
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
