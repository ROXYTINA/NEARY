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
import '../app_widget/main_shell.dart';
import '../features/auth/auth_screen.dart';
import '../features/splash/splash_screen.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
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
            GoRoute(
              path: '/auth',
              builder: (_, state) => AuthScreen(
                redirectTo: state.uri.queryParameters['redirect'],
              ),
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

        // ── Auth-guarded booking route (single, no duplicate) ──
        GoRoute(
          path: '/booking/:salonId',
          builder: (context, state) {
            final auth = context.read<AuthNotifier>();
            final salonId = state.pathParameters['salonId']!;
            if (!auth.isLoggedIn) {
              return AuthScreen(redirectTo: '/booking/$salonId');
            }
            return BookingFlowScreen(salonId: salonId);
          },
        ),

        GoRoute(
          path: '/booking-confirmation',
          builder: (_, __) => const BookingConfirmationScreen(),
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