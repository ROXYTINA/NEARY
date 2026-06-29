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
    final scheme = Theme.of(context).colorScheme;
    final cardColor = Theme.of(context).cardTheme.color ?? scheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Image + badge ──────────────────────────────────
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
                          style: AppTextStyles.displaySm.copyWith(
                              color: Colors.white, fontSize: 17),
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
                          style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.charcoal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Body ───────────────────────────────────────────
            Container(
              color: cardColor,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(promo.description,
                      style: AppTextStyles.bodyMd.copyWith(
                          color: scheme.onSurface),
                      maxLines: 2),
                  const SizedBox(height: 10),

                  // Code box + button
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onCopy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: scheme.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  promo.code,
                                  style: AppTextStyles.labelLg.copyWith(
                                      color: scheme.primary,
                                      letterSpacing: 2),
                                ),
                                Icon(Icons.copy,
                                    size: 16, color: scheme.primary),
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

                  // Expiry + salon name
                  Row(
                    children: [
                      Icon(Icons.schedule,
                          size: 12,
                          color: scheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('Expires ${promo.expiryDate}',
                          style: AppTextStyles.caption.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.5))),
                      const Spacer(),
                      Text(promo.salonName,
                          style: AppTextStyles.caption
                              .copyWith(color: scheme.primary)),
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