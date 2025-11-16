import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize LocalStorageService (includes Hive initialization)
  final localStorageService = LocalStorageService();
  await localStorageService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        // Provide the initialized LocalStorageService instance
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const VKUScheduleApp(),
    ),
  );
}

class VKUScheduleApp extends ConsumerWidget {
  const VKUScheduleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = AppRouter(ref).router;
    
    return MaterialApp.router(
      title: 'VKU Schedule',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}


