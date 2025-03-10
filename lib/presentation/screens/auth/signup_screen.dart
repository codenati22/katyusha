import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/core/exceptions/app_exception.dart';
import 'package:katyusha/domain/entities/user.dart';
import 'package:katyusha/main.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:katyusha/presentation/widgets/custom_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _department = 'Computer Science';
  int _programDuration = 4;
  final _initialCGPAController = TextEditingController();
  bool _isLoading = false;

  final departments = [
    'Computer Science',
    'Engineering',
    'Marketing',
    'unk',
    'duh!',
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Sign Up')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CustomTextField(
                controller: _fullNameController,
                placeholder: 'Full Name',
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Department: '),
                  Expanded(
                    child: CupertinoButton(
                      child: Text(_department),
                      onPressed: () => _showDepartmentPicker(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Program Duration (years): '),
                  CupertinoButton(
                    child: Text('$_programDuration'),
                    onPressed: () => _showDurationPicker(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _initialCGPAController,
                placeholder: 'Initial CGPA (optional)',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CupertinoActivityIndicator()
                  : CupertinoButton.filled(
                    child: const Text('Sign Up'),
                    onPressed: _signup,
                  ),
              const SizedBox(height: 10),
              CupertinoButton(
                child: const Text('Login Instead'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDepartmentPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32,
              onSelectedItemChanged:
                  (index) => setState(() => _department = departments[index]),
              children: departments.map((d) => Text(d)).toList(),
            ),
          ),
    );
  }

  void _showDurationPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (_) => SizedBox(
            height: 200,
            child: CupertinoPicker(
              itemExtent: 32,
              onSelectedItemChanged:
                  (value) => setState(() => _programDuration = value + 1),
              children: List.generate(6, (index) => Text('${index + 1}')),
            ),
          ),
    );
  }

  Future<void> _signup() async {
    setState(() => _isLoading = true);
    try {
      final user = User(
        fullName: _fullNameController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        department: _department,
        programDuration: _programDuration,
        initialCgpa: double.tryParse(_initialCGPAController.text) ?? 0.0,
      );
      await ref.read(authStateProvider.notifier).signup(user);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => const TabNavigator()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is DuplicateUsernameException) {
          errorMessage = e.message;
        } else {
          errorMessage = 'An unexpected error occurred. Please try again.';
        }
        showCupertinoDialog(
          context: context,
          builder:
              (_) => CupertinoAlertDialog(
                title: const Text('Sign Up Failed'),
                content: Text(errorMessage),
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
