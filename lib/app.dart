import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme/app_theme.dart';
import 'app_router/app_router.dart';
import 'app_state/notifiers.dart';

class SalonBeautyApp extends StatelessWidget {
  const SalonBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
    final router = AppRouter.router(context);

    return MaterialApp.router(
      title: 'Neary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.mode,   // ← driven by notifier now
      routerConfig: router,
    );
  }
}