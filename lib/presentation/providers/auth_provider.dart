import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/domain/entities/user.dart';
import 'package:katyusha/domain/usecases/auth/login.dart';
import 'package:katyusha/domain/usecases/auth/signup.dart';
import 'package:katyusha/injection_container.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<User?> {
  final Ref ref;

  AuthNotifier(this.ref) : super(null);

  Future<User?> login(String username, String password) async {
    final user = await sl<Login>().call(username, password);
    state = user;
    return user;
  }

  Future<User> signup(User user) async {
    final newUser = await sl<Signup>().call(user);
    state = newUser;
    return newUser;
  }

  void logout() {
    state = null;
  }
}
