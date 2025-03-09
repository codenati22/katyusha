import 'package:get_it/get_it.dart';
import 'package:katyusha/data/datasources/local/database/db_helper.dart';
import 'package:katyusha/data/repositories/academic_repository_impl.dart';
import 'package:katyusha/data/repositories/auth_repository_impl.dart';
import 'package:katyusha/domain/entities/user.dart'; // Add this import
import 'package:katyusha/domain/usecases/academic/calculate_cgpa.dart';
import 'package:katyusha/domain/usecases/auth/login.dart';
import 'package:katyusha/domain/usecases/auth/signup.dart';

final sl = GetIt.instance;

void init() {
  sl.registerLazySingleton<DBHelper>(() => DBHelper());

  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(sl<DBHelper>()),
  );
  sl.registerLazySingleton<AcademicRepositoryImpl>(
    () => AcademicRepositoryImpl(sl<DBHelper>()),
  );

  sl.registerLazySingleton<Login>(() => Login(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton<Signup>(() => Signup(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton<CalculateCGPA>(() => CalculateCGPA());

  sl.registerFactory<User>(
    () => User(
      id: 0,
      fullName: '',
      username: '',
      password: '',
      department: '',
      programDuration: 4,
      initialCgpa: 0.0,
    ),
  );
}
