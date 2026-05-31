import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'shimmer_widgets.dart';

class SalonCard extends StatelessWidget {
  final Salon salon;
  final bool isFav;
  final VoidCallback onFav;
  final VoidCallback onTap;
  final bool compact;

  const SalonCard({
    super.key,
    required this.salon,
    required this.isFav,
    required this.onFav,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: compact ? 200 : double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.roseDark.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Stack(
              children: [
                Hero(
                  tag: 'salon_${salon.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: salon.coverImage,
                      height: compact ? 130 : 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => shimmerBox(compact ? 130 : 180),
                      errorWidget: (_, __, ___) => errorBox(compact ? 130 : 180),
                    ),
                  ),
                ),
                // Open/closed badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: salon.isOpen
                          ? AppColors.success.withValues(alpha: 0.9)
                          : AppColors.warmGrey.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      salon.isOpen ? 'Open' : 'Closed',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                // Fav button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFav,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                            color: isFav
                            ? AppColors.rosePrimary
                            : Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? Colors.white : AppColors.rosePrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(salon.name,
                      style: AppTextStyles.displaySm
                          .copyWith(fontSize: compact ? 16 : 20),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(salon.tagline,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: salon.rating,
                        itemBuilder: (_, __) =>
                        const Icon(Icons.star, color: AppColors.goldMid),
                        itemCount: 5,
                        itemSize: 14,
                      ),
                      const SizedBox(width: 6),
                      Text('${salon.rating}',
                          style: AppTextStyles.labelMd
                              .copyWith(color: AppColors.goldDeep)),
                      const SizedBox(width: 4),
                      Text('(${salon.reviewCount})',
                          style: AppTextStyles.caption),
                    ],
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.warmGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(salon.address,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('${salon.distance}km',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.rosePrimary)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: salon.categories
                          .take(3)
                          .map((c) => _CategoryChip(label: c))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSm),
    );
  }
}
