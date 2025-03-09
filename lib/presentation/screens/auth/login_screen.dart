import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/main.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katyusha/presentation/screens/auth/signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _stayLoggedIn = false; // New state for "stay logged in" option

  @override
  void initState() {
    super.initState();
    _checkAutoLogin(); // Check for auto-login on init
  }

  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        _stayLoggedIn = true;
      });
      await _login(); // Auto-login if credentials exist
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              decoration: BoxDecoration(
                color: CupertinoColors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _usernameController,
                    placeholder: 'Username',
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    placeholder: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CupertinoSwitch(
                        value: _stayLoggedIn,
                        onChanged: (value) {
                          setState(() {
                            _stayLoggedIn = value;
                          });
                        },
                        activeColor: CupertinoColors.activeBlue,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Stay Logged In',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CupertinoActivityIndicator()
                      : CupertinoButton.filled(
                        child: const Text('Login'),
                        onPressed: _login,
                      ),
                  const SizedBox(height: 10),
                  CupertinoButton(
                    child: const Text('Sign Up Instead'),
                    onPressed:
                        () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SignupScreen(),
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref
          .read(authStateProvider.notifier)
          .login(_usernameController.text, _passwordController.text);
      if (user != null && mounted) {
        if (_stayLoggedIn) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', _usernameController.text);
          await prefs.setString('password', _passwordController.text);
        }
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => const TabNavigator()),
          (route) => false,
        );
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

// Assuming CustomTextField is defined elsewhere (unchanged as per request)
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscureText,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      style: const TextStyle(fontSize: 16),
    );
  }
}
