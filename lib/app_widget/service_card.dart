import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

class ServiceCard extends StatelessWidget {
  final SalonService service;
  final bool isSelected;
  final bool isFav;
  final VoidCallback? onTap;
  final VoidCallback? onFav;

  const ServiceCard({
    super.key,
    required this.service,
    this.isSelected = false,
    this.isFav = false,
    this.onTap,
    this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.roseLight
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.rosePrimary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Category icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.roseLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForCategory(service.category),
                  color: AppColors.rosePrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name,
                        style: AppTextStyles.displaySm
                            .copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined,
                            size: 12, color: AppColors.warmGrey),
                        const SizedBox(width: 4),
                        Text(service.durationLabel,
                            style: AppTextStyles.caption),
                        const SizedBox(width: 12),
                        RatingBarIndicator(
                          rating: service.rating,
                          itemBuilder: (_, __) =>
                          const Icon(Icons.star, color: AppColors.goldMid),
                          itemCount: 5,
                          itemSize: 11,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${service.price.toStringAsFixed(0)}',
                      style: AppTextStyles.priceSm),
                  if (onFav != null)
                    GestureDetector(
                      onTap: onFav,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav ? AppColors.rosePrimary : AppColors.softGrey,
                      ),
                    ),
                ],
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle,
                      color: AppColors.rosePrimary, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Hair':
        return Icons.content_cut;
      case 'Nails':
        return Icons.back_hand_outlined;
      case 'Makeup':
        return Icons.face_retouching_natural;
      case 'Spa':
        return Icons.spa_outlined;
      case 'Bridal':
        return Icons.favorite_outline;
      default:
        return Icons.auto_awesome;
    }
  }
}
