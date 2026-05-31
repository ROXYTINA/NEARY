import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app_theme/app_colors.dart';

Widget shimmerBox(double height) => Shimmer.fromColors(
  baseColor: AppColors.roseLight,
  highlightColor: AppColors.blushWhite,
  child: Container(
    height: height,
    color: AppColors.roseLight,
  ),
);

Widget errorBox(double height) => Container(
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
