import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'shimmer_widgets.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promo;
  final VoidCallback onCopy;
  final VoidCallback onUse;

  const PromotionCard({
    super.key,
    required this.promo,
    required this.onCopy,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.roseDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Image + badge
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: promo.image,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => shimmerBox(120),
                  errorWidget: (_, __, ___) => errorBox(120),
                ),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                        colors: [
                         Colors.transparent,
                         Colors.black.withValues(alpha: 0.6),
                       ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          promo.title,
                          style: AppTextStyles.displaySm
                              .copyWith(color: Colors.white, fontSize: 17),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldMid,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          promo.discountPercent > 0
                              ? '${promo.discountPercent}% OFF'
                              : 'FREE',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.charcoal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Body
            Container(
              color: Theme.of(context).cardTheme.color,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(promo.description,
                      style: AppTextStyles.bodyMd, maxLines: 2),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Code box
                      Expanded(
                        child: GestureDetector(
                          onTap: onCopy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.roseLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.roseMid,
                                  style: BorderStyle.solid),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(promo.code,
                                    style: AppTextStyles.labelLg.copyWith(
                                        color: AppColors.rosePrimary,
                                        letterSpacing: 2)),
                                const Icon(Icons.copy,
                                    size: 16, color: AppColors.rosePrimary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: onUse,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Use Now'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 12, color: AppColors.warmGrey),
                      const SizedBox(width: 4),
                      Text('Expires ${promo.expiryDate}',
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Text(promo.salonName,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.rosePrimary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
