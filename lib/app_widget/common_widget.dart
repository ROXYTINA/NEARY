import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

// ============================================================
// Salon Card
// ============================================================
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
                      placeholder: (_, __) => _shimmerBox(compact ? 130 : 180),
                      errorWidget: (_, __, ___) => _errorBox(compact ? 130 : 180),
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

// ============================================================
// Service Card
// ============================================================
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

// ============================================================
// Promotion Card
// ============================================================
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
                  placeholder: (_, __) => _shimmerBox(120),
                  errorWidget: (_, __, ___) => _errorBox(120),
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

// ============================================================
// Shimmer helpers
// ============================================================
Widget _shimmerBox(double height) => Shimmer.fromColors(
  baseColor: AppColors.roseLight,
  highlightColor: AppColors.blushWhite,
  child: Container(
    height: height,
    color: AppColors.roseLight,
  ),
);

Widget _errorBox(double height) => Container(
  height: height,
  color: AppColors.roseLight,
  child: const Center(
    child: SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
);

// ============================================================
// Section Header
// ============================================================
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.displaySm),
                if (subtitle != null)
                  Text(subtitle!, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text('See All'),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.roseLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.roseDark),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: AppTextStyles.displaySm,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.warmGrey),
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Shimmer Card List
// ============================================================
class ShimmerCardList extends StatelessWidget {
  final int count;
  const ShimmerCardList({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.roseLight,
        highlightColor: AppColors.blushWhite,
        child: Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.roseLight,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Star Rating Row
// ============================================================
class StarRatingRow extends StatelessWidget {
  final double rating;
  final int count;

  const StarRatingRow({super.key, required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (_, __) =>
          const Icon(Icons.star, color: AppColors.goldMid),
          itemCount: 5,
          itemSize: 16,
        ),
        const SizedBox(width: 6),
        Text('$rating', style: AppTextStyles.labelLg),
        const SizedBox(width: 4),
        Text('($count)', style: AppTextStyles.caption),
      ],
    );
  }
}

// ============================================================
// Primary CTA Button
// ============================================================
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.button),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Stylist Card
// ============================================================
class StylistCard extends StatelessWidget {
  final Stylist stylist;
  final bool isSelected;
  final VoidCallback? onTap;

  const StylistCard({super.key, required this.stylist, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.roseLight : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.rosePrimary : AppColors.divider, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            NetworkAvatar(
              imageUrl: stylist.avatar,
              radius: 34,
              icon: Icons.person,
            ),
            const SizedBox(height: 8),
            Text(stylist.name, style: AppTextStyles.labelLg, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(stylist.role, style: AppTextStyles.caption.copyWith(color: AppColors.warmGrey)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.goldMid),
                const SizedBox(width: 4),
                Text(stylist.rating.toStringAsFixed(1), style: AppTextStyles.labelSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NetworkAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final IconData icon;

  const NetworkAvatar({
    super.key,
    required this.imageUrl,
    required this.radius,
    this.icon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.roseLight,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: SafeNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            fallbackSize: radius * 2,
          ),
        ),
      ),
    );
  }
}

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? fallbackSize;
  final Color backgroundColor;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackSize,
    this.backgroundColor = AppColors.roseLight,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = _normalizeNetworkUrl(imageUrl);
    if (kDebugMode) {
      debugPrint('SafeNetworkImage: rawUrl=${imageUrl ?? 'null'} resolvedUrl=${resolved ?? 'invalid'}');
    }

    if (resolved == null) {
      return _imageFallback(
        width: width,
        height: height,
        size: fallbackSize,
        backgroundColor: backgroundColor,
      );
    }

    return Image.network(
      resolved,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _imageLoading(
          width: width,
          height: height,
          backgroundColor: backgroundColor,
        );
      },
      errorBuilder: (_, __, ___) => _imageFallback(
        width: width,
        height: height,
        size: fallbackSize,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

class SafeAssetImage extends StatelessWidget {
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double? fallbackSize;
  final Color backgroundColor;

  const SafeAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackSize,
    this.backgroundColor = AppColors.roseLight,
  });

  @override
  Widget build(BuildContext context) {
    final path = assetPath?.trim();
    if (path == null || path.isEmpty) {
      return _imageFallback(
        width: width,
        height: height,
        size: fallbackSize,
        backgroundColor: backgroundColor,
      );
    }

    return Image(
      image: AssetImage(path),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return _imageLoading(
          width: width,
          height: height,
          backgroundColor: backgroundColor,
        );
      },
      errorBuilder: (_, __, ___) => _imageFallback(
        width: width,
        height: height,
        size: fallbackSize,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

Widget _imageLoading({
  double? width,
  double? height,
  required Color backgroundColor,
}) {
  return Container(
    width: width,
    height: height,
    color: backgroundColor,
    alignment: Alignment.center,
    child: const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

Widget _imageFallback({
  double? width,
  double? height,
  double? size,
  required Color backgroundColor,
}) {
  return Container(
    width: width,
    height: height,
    color: backgroundColor,
    alignment: Alignment.center,
    child: SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: const CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

String? _normalizeNetworkUrl(String? rawUrl) {
  final value = rawUrl?.trim();
  if (value == null || value.isEmpty) return null;

  final uri = Uri.tryParse(value);
  if (uri == null) return null;

  if (!uri.hasScheme || uri.host.isEmpty) {
    return null;
  }

  if (defaultTargetPlatform == TargetPlatform.android &&
      (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
    return uri.replace(host: '10.0.2.2').toString();
  }

  return uri.toString();
}

// ============================================================
// Time Slot Picker
// ============================================================
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
