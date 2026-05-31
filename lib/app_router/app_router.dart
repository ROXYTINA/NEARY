import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_state/notifiers.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/home/home_screen.dart';
import '../features/salon_detail/salon_detail_screen.dart';
import '../features/service_detail/service_detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/map/map_screen.dart';
import '../features/nearby/nearby_screen.dart';
import '../features/promotions/promotions_screen.dart';
import '../features/booking/booking_flow_screen.dart';
import '../features/booking/booking_confirmation_screen.dart';
import '../features/my_bookings/my_bookings_screen.dart';
import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_thread_screen.dart';
import '../features/reviews/reviews_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/main_shell.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    final onboarding = context.read<OnboardingNotifier>();

    return GoRouter(
      initialLocation: onboarding.isDone ? '/home' : '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
            GoRoute(
              path: '/favorites',
              builder: (_, __) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/map',
              builder: (_, __) => const MapScreen(),
            ),
            GoRoute(
              path: '/nearby',
              builder: (_, __) => const NearbyScreen(),
            ),
            GoRoute(
              path: '/promotions',
              builder: (_, __) => const PromotionsScreen(),
            ),
            GoRoute(
              path: '/my-bookings',
              builder: (_, __) => const MyBookingsScreen(),
            ),
            GoRoute(
              path: '/chat',
              builder: (_, __) => const ChatListScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/salon/:id',
          builder: (_, state) => SalonDetailScreen(
            salonId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/service/:id',
          builder: (_, state) => ServiceDetailScreen(
            serviceId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/booking/:salonId',
          builder: (_, state) => BookingFlowScreen(
            salonId: state.pathParameters['salonId']!,
          ),
        ),
        GoRoute(
          path: '/booking-confirmation',
          builder: (_, state) => const BookingConfirmationScreen(),
        ),
        GoRoute(
          path: '/chat/:salonId',
          builder: (_, state) => ChatThreadScreen(
            salonId: state.pathParameters['salonId']!,
          ),
        ),
        GoRoute(
          path: '/reviews/:salonId',
          builder: (_, state) => ReviewsScreen(
            salonId: state.pathParameters['salonId']!,
          ),
        ),
        GoRoute(
          path: '/gallery/:salonId',
          builder: (_, state) => GalleryScreen(
            salonId: state.pathParameters['salonId']!,
          ),
        ),
      ],
    );
  }
}