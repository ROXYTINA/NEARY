import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/notifiers.dart';
import '../../app_theme/app_text_styles.dart';

import '../../app_theme/app_colors.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboarding = context.read<OnboardingNotifier>();
      if (onboarding.isDone) {
        context.go('/home');
      }
    });
  }

  final _pages = [
    {
      'emoji': '💇‍♀️',
      'title': 'Discover Nearby Salons',
      'body': 'Find top-rated salons and services near you.',
    },
    {
      'emoji': '📅',
      'title': 'Book Appointments Easily',
      'body': 'Multi-step booking, calendar, and stylist selection.',
    },
    {
      'emoji': '🎁',
      'title': 'Exclusive Promotions',
      'body': 'Save with coupon codes and seasonal offers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.read<OnboardingNotifier>();
    final scheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_page > 0) setState(() => _page--);
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [

              // ── Logo small at top ──────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Image.asset(
                  'assets/images/img.png',
                  height: 80,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.spa, size: 60, color: AppColors.rosePrimary),
                ),
              ),

              // ── Pages ──────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Emoji icon
                        Text(
                          _pages[i]['emoji']!,
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _pages[i]['title']!,
                          style: AppTextStyles.heroDisplay.copyWith(
                            color: scheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[i]['body']!,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Dot indicators ─────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i
                          ? AppColors.rosePrimary
                          : AppColors.roseMid,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Buttons ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await onboarding.complete();
                        if (mounted) context.go('/home');
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            color: scheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (_page < _pages.length - 1) {
                          setState(() => _page++);
                        } else {
                          await onboarding.complete();
                          if (mounted) context.go('/home');
                        }
                      },
                      child: Text(
                        _page < _pages.length - 1 ? 'Next' : 'Get Started',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}