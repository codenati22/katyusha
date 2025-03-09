import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double cgpa;

  const ProgressIndicatorWidget({super.key, required this.cgpa});

  @override
  Widget build(BuildContext context) {
    final normalizedCgpa = cgpa.clamp(0.0, 4.0);
    final progress = normalizedCgpa / 4.0;
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: const AlwaysStoppedAnimation(
              CupertinoColors.activeBlue,
            ),
          ),
          Text(
            '${(cgpa * 25).toInt()}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
