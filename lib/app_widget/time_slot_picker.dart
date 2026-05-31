import 'package:flutter/material.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

class TimeSlotPicker extends StatelessWidget {
  final List<String> slots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  const TimeSlotPicker({super.key, required this.slots, required this.onSlotSelected, this.selectedSlot});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const Text('No slots available');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: slots.map((s) {
        final selected = s == selectedSlot;
        return GestureDetector(
          onTap: () => onSlotSelected(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.rosePrimary : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: selected ? AppColors.rosePrimary : AppColors.divider),
            ),
            child: Text(s, style: selected ? AppTextStyles.labelMd.copyWith(color: Colors.white) : AppTextStyles.labelMd),
          ),
        );
      }).toList(),
    );
  }
}
