
import 'package:flutter/material.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'common_widget.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.rosePrimary.withOpacity(0.08)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.rosePrimary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.rosePrimary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Avatar + selected badge ──────────────────
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  NetworkAvatar(
                    imageUrl: stylist.avatar,
                    radius: 36,
                    icon: Icons.person,
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppColors.rosePrimary,
                        size: 18,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Name ────────────────────────────────────
              Text(
                stylist.name,
                style: AppTextStyles.labelLg,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // ── Role ────────────────────────────────────
              Text(
                stylist.role,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.warmGrey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // ── Rating ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.goldMid.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 13, color: AppColors.goldMid),
                    const SizedBox(width: 3),
                    Text(
                      stylist.rating.toStringAsFixed(1),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.goldMid,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Skills ──────────────────────────────────
              if (stylist.skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: stylist.skills.take(2).map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.rosePrimary.withOpacity(0.12)
                            : AppColors.roseLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.rosePrimary
                              : AppColors.warmGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}