class User {
  final String? id;
  final String fullName;
  final String username;
  final String password;
  final String department;
  final int programDuration;
  final int semestersPerYear;
  final double initialCGPA;

  User({
    this.id,
    required this.fullName,
    required this.username,
    required this.password,
    required this.department,
    required this.programDuration,
    required this.semestersPerYear,
    required this.initialCGPA,
  });
}
