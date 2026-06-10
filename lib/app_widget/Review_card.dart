
import 'package:flutter/material.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'common_widget.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final rating = review.rating.toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ─────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NetworkAvatar(
                  imageUrl: review.userAvatar,
                  radius: 22,
                  icon: Icons.person,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName, style: AppTextStyles.labelLg),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // filled stars
                          ...List.generate(
                            rating,
                                (_) => const Icon(Icons.star_rounded,
                                size: 15, color: AppColors.goldMid),
                          ),
                          // empty stars
                          ...List.generate(
                            5 - rating,
                                (_) => Icon(Icons.star_rounded,
                                size: 15,
                                color: AppColors.goldMid.withOpacity(0.2)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.goldMid,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Date pill ────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.roseLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    review.date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.rosePrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Comment ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.roseLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                review.comment,
                style: AppTextStyles.bodyMd,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}