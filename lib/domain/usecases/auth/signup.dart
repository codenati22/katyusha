import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class Signup {
  final AuthRepository repository;

  Signup(this.repository);

  Future<User> call(User user) {
    return repository.signup(user);
  }
}
