import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';

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

    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.beforeAfterImages.isNotEmpty)
              SafeNetworkImage(
                imageUrl: service.beforeAfterImages.first,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: AppTextStyles.heroDisplay),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${service.price.toStringAsFixed(0)}', style: AppTextStyles.displaySm),
                      Text(service.durationLabel, style: AppTextStyles.labelLg),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Description', style: AppTextStyles.titleLg),
                  const SizedBox(height: 8),
                  Text(service.description, style: AppTextStyles.bodyMd),
                  const SizedBox(height: 16),
                  const Text('Rating', style: AppTextStyles.titleLg),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(Icons.star,
                        color: i < service.rating.toInt() ? AppColors.goldMid : AppColors.divider)),
                      const SizedBox(width: 8),
                      Text('${service.rating}', style: AppTextStyles.labelLg),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/booking/${service.salonId}'),
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

