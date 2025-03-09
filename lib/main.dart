import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:katyusha/injection_container.dart' as di;
import 'package:katyusha/presentation/providers/auth_provider.dart';
import 'package:katyusha/presentation/screens/auth/login_screen.dart';
import 'package:katyusha/presentation/screens/home/home_screen.dart';
import 'package:katyusha/presentation/screens/me/me_screen.dart';
import 'package:katyusha/presentation/widgets/navigation_drawer.dart';
import 'core/utils/logger.dart';

void main() {
  di.init();
  runApp(const ProviderScope(child: KatyushaApp()));
}

class KatyushaApp extends ConsumerWidget {
  const KatyushaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    Logger.log('User state: ${user != null ? "Logged in" : "Not logged in"}');
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'Katyusha',
      home:
          user == null
              ? const Banner(
                location: BannerLocation.topEnd,
                message: "Etsub",
                child: LoginScreen(),
              )
              : const Banner(
                location: BannerLocation.topEnd,
                message: "Etsub",
                child: TabNavigator(),
              ),
      theme: const CupertinoThemeData(brightness: Brightness.light),
    );
  }
}

class TabNavigator extends StatefulWidget {
  const TabNavigator({super.key});

  @override
  _TabNavigatorState createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerAnimation = Tween<double>(begin: -250, end: 0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    Logger.log('Toggling drawer: $_isDrawerOpen -> ${!_isDrawerOpen}');
    if (_isDrawerOpen) {
      _drawerController.reverse().then((_) {
        setState(() => _isDrawerOpen = false);
      });
    } else {
      setState(() => _isDrawerOpen = true);
      _drawerController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.log('Building TabNavigator, drawer open: $_isDrawerOpen');
    return Stack(
      children: [
        CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                label: 'Me',
              ),
            ],
            onTap: (index) {
              Logger.log('Tab tapped: $index');
            },
          ),
          tabBuilder: (context, index) {
            Logger.log('Tab index: $index');
            return CupertinoTabView(
              builder: (context) {
                switch (index) {
                  case 0:
                    return HomeScreen(onDrawerToggle: _toggleDrawer);
                  case 1:
                    return MeScreen(onDrawerToggle: _toggleDrawer);
                  default:
                    return HomeScreen(onDrawerToggle: _toggleDrawer);
                }
              },
            );
          },
        ),
        if (_isDrawerOpen)
          AnimatedBuilder(
            animation: _drawerAnimation,
            builder:
                (context, child) => Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _toggleDrawer,
                        child: Container(
                          color: CupertinoColors.black.withOpacity(
                            _drawerController.value * 0.7,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _drawerAnimation.value,
                      top: 0,
                      bottom: 0,
                      width: 250,
                      child: NavigationDrawer(onClose: _toggleDrawer),
                    ),
                  ],
                ),
          ),
      ],
    );
  }
}
