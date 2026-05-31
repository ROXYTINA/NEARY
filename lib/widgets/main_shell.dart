import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  static const _routes = ['/home', '/favorites', '/map', '/promotions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          GoRouter.of(context).go(_routes[i]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: 'Promos'),
        ],
      ),
    );
  }
}

