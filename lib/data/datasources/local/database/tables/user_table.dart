class UserTable {
  static const String tableName = 'users';
  static const String createTable = '''
    CREATE TABLE $tableName (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      department TEXT NOT NULL,
      program_duration INTEGER NOT NULL,
      initial_cgpa REAL DEFAULT 0.0
    )
  ''';

  static Map<String, dynamic> toMap(Map<String, dynamic> user) {
    return {
      'id': user['id'],
      'full_name': user['full_name'],
      'username': user['username'],
      'password': user['password'],
      'department': user['department'],
      'program_duration': user['program_duration'],
      'initial_cgpa': user['initial_cgpa'],
    };
  }
}
