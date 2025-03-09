import 'package:flutter/cupertino.dart';
import 'package:katyusha/domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(course.name),
      subtitle: Text('${course.creditHours} credits - Grade: ${course.grade}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            child: const Icon(CupertinoIcons.pencil),
            onPressed: onEdit,
          ),
          CupertinoButton(
            child: const Icon(CupertinoIcons.trash),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
