import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../app_theme/app_colors.dart';
import '../app_theme/app_text_styles.dart';

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
