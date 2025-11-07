import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'utils/theme.dart';
import 'screens/oauth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/permissions_screen.dart';
import 'utils/notifications.dart';
import 'utils/permission_handler.dart' as app_permissions;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SuvyAIkth',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: const _EntryGate(),
    );
  }
}

class _EntryGate extends StatefulWidget {
  const _EntryGate();

  @override
  State<_EntryGate> createState() => _EntryGateState();
}

class _EntryGateState extends State<_EntryGate> {
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return OAuthScreen(
        onSignedIn: () async {
          setState(() => _signedIn = true);
        },
      );
    }
    return const _AppShell();
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;
  final _pages = const [
    HomeScreen(),
    TasksScreen(),
    ProgressScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];
  static bool _firstLaunched = false;
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runFirstLaunchFlow();
    });
  }

  Future<void> _runFirstLaunchFlow() async {
    if (_firstLaunched) return;
    _firstLaunched = true;
    
    // Check if we have all permissions
    final hasAll = await app_permissions.AppPermissions.hasAllPermissions();
    if (!hasAll && mounted) {
      // Show permissions screen
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => const PermissionsScreen(),
        ),
      );
      
      if (result == true) {
        setState(() => _permissionsGranted = true);
      }
    } else {
      setState(() => _permissionsGranted = true);
    }
    
    // Show thank you notification
    try {
      await Notifications.showThankYou();
    } catch (_) {}
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check permissions again when coming back to the app
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final hasAll = await app_permissions.AppPermissions.hasAllPermissions();
      if (mounted && hasAll != _permissionsGranted) {
        setState(() => _permissionsGranted = hasAll);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), selectedIcon: Icon(Icons.show_chart), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
