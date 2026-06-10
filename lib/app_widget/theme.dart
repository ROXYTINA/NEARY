
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state/notifiers.dart';
import '../app_theme/app_colors.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeNotifier>();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _ThemeOption(
            icon: Icons.brightness_auto,
            label: 'AUTO',
            selected: theme.isSystem,
            onTap: () => theme.setMode(ThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            label: 'GIRLY',
            selected: theme.isLight,
            onTap: () => theme.setMode(ThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            label: 'Dark',
            selected: theme.isDark,
            onTap: () => theme.setMode(ThemeMode.dark),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.rosePrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? Colors.white : AppColors.warmGrey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? Colors.white : AppColors.warmGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}