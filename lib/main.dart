import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data/mock_repository.dart';
import 'app_state/notifiers.dart';
import 'app_state/api_settings.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final cacheManager = DefaultCacheManager();
  // await cacheManager.emptyCache();
  await MockRepository.instance.init();

  final onboarding = OnboardingNotifier();
  final favorites = FavoritesNotifier();
  final booking = BookingNotifier();
  final chat = ChatNotifier();
  final apiSettings = ApiSettingsNotifier();

  final theme = ThemeNotifier();
  await theme.load();

  await onboarding.load();
  await booking.load(apiSettings.baseUrl);
  await favorites.load();
  await favorites.rehydrate(apiSettings.baseUrl);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: favorites),
        ChangeNotifierProvider.value(value: booking),
        ChangeNotifierProvider.value(value: chat),
        ChangeNotifierProvider.value(value: apiSettings),
        ChangeNotifierProvider(create: (_) => AuthNotifier()..load()),
        ChangeNotifierProvider.value(value: theme),
      ],
      child: const SalonBeautyApp(),
    ),
  );
}

// class DefaultCacheManager {
//   Future<void> emptyCache() async {}
// }