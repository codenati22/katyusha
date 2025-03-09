class User {
  final int? id;
  final String fullName;
  final String username;
  final String password;
  final String department;
  final int programDuration;
  final double initialCgpa;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.department,
    required this.programDuration,
    this.initialCgpa = 0.0,
  });
}
