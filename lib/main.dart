// ============================================================
// main.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data/mock_repository.dart';
import 'app_state/notifiers.dart';
import 'app_state/api_settings.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockRepository.instance.init();

  final onboarding = OnboardingNotifier();
  final favorites = FavoritesNotifier();
  final booking = BookingNotifier();
  final chat = ChatNotifier();
  final apiSettings = ApiSettingsNotifier();

  await onboarding.load();
  await favorites.load();
  await booking.load(apiSettings.baseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: favorites),
        ChangeNotifierProvider.value(value: booking),
        ChangeNotifierProvider.value(value: chat),
        ChangeNotifierProvider.value(value: apiSettings),
      ],
      child: const SalonBeautyApp(),
    ),
  );
}