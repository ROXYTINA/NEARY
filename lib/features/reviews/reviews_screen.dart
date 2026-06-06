import 'package:flutter/material.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';

class ReviewsScreen extends StatelessWidget {
  final String salonId;
  const ReviewsScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    final reviews = MockRepository.instance.getReviewsForSalon(salonId);
    
    return Scaffold(
      backgroundColor: AppColors.blushWhite,
      appBar: AppBar(
        title: const Text('Reviews'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: reviews.isEmpty
          ? Center(
              child: Text('No reviews yet.', style: AppTextStyles.bodyLg),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.divider, height: 32),
              itemBuilder: (_, i) {
                final r = reviews[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (r.userAvatar.isNotEmpty)
                          NetworkAvatar(
                            imageUrl: r.userAvatar,
                            radius: 24,
                            icon: Icons.person,
                          )
                        else
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.goldLight,
                            child: Text(
                              r.userName.isNotEmpty ? r.userName.substring(0, 1).toUpperCase() : 'U',
                              style: AppTextStyles.labelLg.copyWith(color: AppColors.goldAccent),
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.userName, style: AppTextStyles.labelLg),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: index < r.rating ? AppColors.goldMid : AppColors.starEmpty,
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          r.date,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    if (r.service.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Service: ${r.service}',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.rosePrimary),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      r.comment,
                      style: AppTextStyles.bodyMd,
                    ),
                  ],
                );
              },
            ),
    );
  }
}
