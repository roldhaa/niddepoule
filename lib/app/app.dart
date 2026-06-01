import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/router/app_router.dart';
import 'package:niddepoule/app/theme/app_theme.dart';
import 'package:niddepoule/app/theme/theme_provider.dart';

class CivicRoadApp extends ConsumerWidget {
  const CivicRoadApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp.router(
      title: 'CivicRoad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

