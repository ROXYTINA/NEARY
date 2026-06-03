import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/notifiers.dart';
import '../../app_theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  final _pages = [
    {
      'title': 'Discover Nearby Salons',
      'body': 'Find top-rated salons and services near you.',
    },
    {
      'title': 'Book Appointments Easily',
      'body': 'Multi-step booking, calendar, and stylist selection.',
    },
    {
      'title': 'Exclusive Promotions',
      'body': 'Save with coupon codes and seasonal offers.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final onboarding = context.read<OnboardingNotifier>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_page > 0) {
          setState(() => _page--);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_pages[i]['title']!,
                            style: AppTextStyles.heroDisplay,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(_pages[i]['body']!,
                            style: AppTextStyles.bodyMd,
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        await onboarding.complete();
                        if (mounted) context.go('/home');
                      },
                      child: const Text('Skip'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        if (_page < _pages.length - 1) {
                          setState(() => _page++);
                          // animate page view if needed
                        } else {
                          await onboarding.complete();
                          if (mounted) context.go('/home');
                        }
                      },
                      child: Text(
                          _page < _pages.length - 1 ? 'Next' : 'Get Started'),
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