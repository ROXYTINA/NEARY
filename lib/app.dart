import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'app_theme/app_theme.dart';
import 'app_router/app_router.dart';
import 'app_state/notifiers.dart';

class SalonBeautyApp extends StatefulWidget {
  const SalonBeautyApp({super.key});

  @override
  State<SalonBeautyApp> createState() => _SalonBeautyAppState();
}

class _SalonBeautyAppState extends State<SalonBeautyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(context); // ← created once, never recreated
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp.router(
      title: 'Neary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeNotifier.mode,
      routerConfig: _router, // ← stable reference
    );
  }
}