import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600;

// ── Use this wrapper wherever you render the services list ────────────
//
//   ServiceCardGrid(
//     services: services,
//     selectedId: _selectedId,
//     favIds: _favIds,
//     onTap: (s) => ...,
//     onFav: (s) => ...,
//   )
//
class ServiceCardGrid extends StatelessWidget {
  final List<SalonService> services;
  final String? selectedId;
  final Set<String> favIds;
  final void Function(SalonService) onTap;
  final void Function(SalonService)? onFav;

  const ServiceCardGrid({
    super.key,
    required this.services,
    this.selectedId,
    this.favIds = const {},
    required this.onTap,
    this.onFav,
  });

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    if (tablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 0,
          childAspectRatio: 2.6,
        ),
        itemCount: services.length,
        itemBuilder: (_, i) {
          final s = services[i];
          return ServiceCard(
            service: s,
            isSelected: s.id == selectedId,
            isFav: favIds.contains(s.id),
            onTap: () => onTap(s),
            onFav: onFav != null ? () => onFav!(s) : null,
          );
        },
      );
    }

    return Column(
      children: services
          .map((s) => ServiceCard(
        service: s,
        isSelected: s.id == selectedId,
        isFav: favIds.contains(s.id),
        onTap: () => onTap(s),
        onFav: onFav != null ? () => onFav!(s) : null,
      ))
          .toList(),
    );
  }
}

// ── ServiceCard ───────────────────────────────────────────────────────
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
    final tablet = _isTablet(context);
    final iconSize = tablet ? 60.0 : 50.0;
    final iconInner = tablet ? 28.0 : 24.0;
    final nameFontSize = tablet ? 16.0 : 15.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(tablet ? 16 : 14),
          child: Row(
            children: [

              // Category icon
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForCategory(service.category),
                  color: Theme.of(context).colorScheme.primary,
                  size: iconInner,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.displaySm
                          .copyWith(fontSize: nameFontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '\$${service.price.toStringAsFixed(0)}',
                    style: AppTextStyles.priceSm.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (onFav != null)
                    GestureDetector(
                      onTap: onFav,
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFav
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),

              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
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