import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:katyusha/presentation/screens/academic_status/academic_status_screen.dart';
import 'package:katyusha/presentation/screens/prediction/prediction_screen.dart';
import 'package:katyusha/presentation/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:katyusha/presentation/screens/about/about.dart';

class NavigationDrawer extends ConsumerWidget {
  final VoidCallback onClose;

  const NavigationDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: CupertinoColors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Katyusha',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            CupertinoButton(
              child: const Text('Academic Status'),
              onPressed: () {
                onClose();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => const AcademicStatusScreen(),
                  ),
                );
              },
            ),
            CupertinoButton(
              child: const Text('Prediction'),
              onPressed: () {
                onClose();
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const PredictionScreen()),
                );
              },
            ),
            CupertinoButton(
              child: const Text('About Us'), // Added About Us button
              onPressed: () {
                onClose();
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
            const Spacer(),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text('Logout'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                await prefs.remove('password');
                ref.read(authStateProvider.notifier).logout();
                onClose();
                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
