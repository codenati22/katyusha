import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:katyusha/domain/entities/course.dart';

class GPAChart extends StatelessWidget {
  final List<Course> courses;

  const GPAChart({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 4.0, // Max GPA is 4.0
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipMargin: 10, // Adjust the margin as needed
                tooltipRoundedRadius: 8, // Adjust the rounded radius as needed
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final course = courses[groupIndex];
                  return BarTooltipItem(
                    '${course.name}\n${rod.toY.toStringAsFixed(2)}',
                    const TextStyle(color: CupertinoColors.white),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < courses.length) {
                      return Text(
                        courses[index].name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 30,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget:
                      (value, meta) => Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true, drawVerticalLine: false),
            barGroups:
                courses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final course = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: _gradeToPoint(course.grade),
                        color: CupertinoColors.activeBlue,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  double _gradeToPoint(String grade) {
    const gradePoints = {
      'A+': 4.0,
      'A': 4.0,
      'A-': 3.75,
      'B+': 3.5,
      'B': 3.0,
      'B-': 2.75,
      'C+': 2.5,
      'C': 2.0,
      'C-': 1.75,
      'D': 1.0,
      'F': 0.0,
    };
    return gradePoints[grade.toUpperCase()] ?? 0.0;
  }
}
