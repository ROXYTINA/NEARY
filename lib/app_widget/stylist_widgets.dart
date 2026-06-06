import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'salon_card.dart'; // For NetworkAvatar usually, but we'll include it here if needed

class StylistCard extends StatelessWidget {
  final Stylist stylist;
  final bool isSelected;
  final VoidCallback? onTap;

  const StylistCard({
    super.key,
    required this.stylist,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = (stylist.avatar).trim();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.roseLight
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.rosePrimary
                : AppColors.divider,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.roseLight,
              backgroundImage:
              avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty
                  ? const Icon(Icons.person,
                  color: AppColors.warmGrey)
                  : null,
            ),

            const SizedBox(height: 8),

            Text(
              stylist.name,
              style: AppTextStyles.labelLg,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            Text(
              stylist.role,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.warmGrey),
              maxLines: 1,
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star,
                    size: 14, color: AppColors.goldMid),
                const SizedBox(width: 4),
                Text(
                  stylist.rating.toStringAsFixed(1),
                  style: AppTextStyles.labelSm,
                ),
              ],
            ),

            const SizedBox(height: 6),

            // SKILLS FIX
            if (stylist.skills.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: stylist.skills.take(2).map((s) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.roseLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      s,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}