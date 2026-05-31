import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme/app_theme.dart';
import 'app_router/app_router.dart';
import 'app_state/notifiers.dart';

class SalonBeautyApp extends StatelessWidget {
  const SalonBeautyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingNotifier>();

    final router = AppRouter.router(context);

    return MaterialApp.router(
      title: 'Salon & Beauty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}