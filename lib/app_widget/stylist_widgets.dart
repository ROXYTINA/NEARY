import 'package:flutter/material.dart';
import '../app_model/models.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';
import 'salon_card.dart'; // For NetworkAvatar usually, but we'll include it here if needed

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
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) {
      return Container(width: width, height: height, color: backgroundColor, child: Icon(Icons.image, size: fallbackSize));
    }

    return Image.network(
      value,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(width: width, height: height, color: backgroundColor, child: Icon(Icons.broken_image, size: fallbackSize)),
    );
  }
}
