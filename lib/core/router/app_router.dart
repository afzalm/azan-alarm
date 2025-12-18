/// Go Router configuration for navigation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/screens.dart';

/// App router configuration
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    /// Root redirect
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),

    /// Home shell route with bottom navigation
    ShellRoute(
      builder: (context, state, child) {
        return HomeShell(child: child);
      },
      routes: [
        /// Home screen
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),

        /// Alarms screen
        GoRoute(
          path: '/alarms',
          name: 'alarms',
          builder: (context, state) => const AlarmsScreen(),
        ),

        /// Location screen
        GoRoute(
          path: '/location',
          name: 'location',
          builder: (context, state) => const LocationScreen(),
        ),

        /// Settings screen
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    /// Full-screen routes
    GoRoute(
      path: '/qibla',
      name: 'qibla',
      builder: (context, state) => const QiblaCompassScreen(),
    ),

    GoRoute(
      path: '/calendar',
      name: 'calendar',
      builder: (context, state) => const IslamicCalendarScreen(),
    ),

    /// Modal sheet routes
    GoRoute(
      path: '/alarm-details/:id',
      name: 'alarm-details',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return AlarmDetailsScreen(alarmId: id);
      },
    ),

    GoRoute(
      path: '/location-picker',
      name: 'location-picker',
      builder: (context, state) => const LocationPickerSheet(),
    ),

    GoRoute(
      path: '/create-alarm',
      name: 'create-alarm',
      builder: (context, state) => const AlarmCreationSheet(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);

/// Home shell with bottom navigation
class HomeShell extends StatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  /// Get the current route name
  String get _currentRouteName {
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.last.matchedLocation;
    
    if (location == '/home') return 'home';
    if (location == '/alarms') return 'alarms';
    if (location == '/location') return 'location';
    if (location == '/settings') return 'settings';
    
    return 'home';
  }

  /// Update current index based on route
  void _updateCurrentIndex() {
    final routeName = _currentRouteName;
    setState(() {
      switch (routeName) {
        case 'home':
          _currentIndex = 0;
          break;
        case 'alarms':
          _currentIndex = 1;
          break;
        case 'location':
          _currentIndex = 2;
          break;
        case 'settings':
          _currentIndex = 3;
          break;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/alarms');
              break;
            case 2:
              context.go('/location');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'Location',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}