import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: AzanAlarmApp(),
    ),
  );
}

class AzanAlarmApp extends ConsumerWidget {
  const AzanAlarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      themeMode: ThemeMode.system,
      theme: AppThemeBuilder.buildLightTheme(),
      darkTheme: AppThemeBuilder.buildDarkTheme(),
      
      // Router configuration
      routerConfig: router,
    );
  }
}
