import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_data/mock_repository.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final service = MockRepository.instance.getServiceById(serviceId);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service')),
        body: const Center(child: Text('Service not found')),
      );
    }

    // ✅ Declared inside build() so it's accessible throughout
    final reviews = MockRepository.instance.getReviewsBySalonId(service.salonId);

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            if (service.beforeAfterImages.isNotEmpty)
              CachedNetworkImage(
                imageUrl: service.beforeAfterImages.first,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: AppColors.divider,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: AppColors.divider,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(service.name, style: AppTextStyles.heroDisplay),
                  const SizedBox(height: 8),

                  // Price & Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${service.price.toStringAsFixed(0)}',
                        style: AppTextStyles.displaySm,
                      ),
                      Text(service.durationLabel, style: AppTextStyles.labelLg),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description', style: AppTextStyles.titleLg),
                  const SizedBox(height: 8),
                  Text(service.description, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 16),

                  // Rating
                  const Text('Rating', style: AppTextStyles.titleLg),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                            (i) => Icon(
                          Icons.star,
                          color: i < service.rating.toInt()
                              ? AppColors.goldMid
                              : AppColors.divider,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${service.rating}', style: AppTextStyles.labelLg),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Gallery ────────────────────────────────────────
                  if (service.beforeAfterImages.length > 1) ...[
                    const Text('Gallery', style: AppTextStyles.titleLg),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: service.beforeAfterImages.length,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: service.beforeAfterImages[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: AppColors.divider),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // ── Reviews ────────────────────────────────────────
                  if (reviews.isNotEmpty) ...[
                    Text(
                      'Reviews (${reviews.length})',
                      style: AppTextStyles.titleLg,
                    ),
                    const SizedBox(height: 12),
                    ...reviews.map((review) => _ReviewCard(review: review)),
                    const SizedBox(height: 24), // ✅ comma handled by spread
                  ],

                  // ── Book Button ────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          context.go('/booking/${service.salonId}'),
                      child: const Text('Book Service'),
                    ),
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

class _ReviewCard extends StatelessWidget {
  final dynamic review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.roseMid,
                backgroundImage:
                (review.avatarUrl != null && review.avatarUrl!.isNotEmpty)
                    ? CachedNetworkImageProvider(review.avatarUrl!)
                    : null,
                child:
                (review.avatarUrl == null || review.avatarUrl!.isEmpty)
                    ? Text(
                  review.authorName.isNotEmpty
                      ? review.authorName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.labelLg,
                )
                    : null,
              ),
              const SizedBox(width: 10),

              // Name & stars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName, style: AppTextStyles.labelLg),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < review.rating.toInt()
                              ? AppColors.goldMid
                              : AppColors.divider,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Date
              if (review.createdAt != null)
                Text(
                  '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                  style: AppTextStyles.bodyMd,
                ),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!, style: AppTextStyles.bodyMd),
          ],
        ],
      ),
    );
  }
}