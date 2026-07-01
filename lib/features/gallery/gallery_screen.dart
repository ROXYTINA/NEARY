import 'package:flutter/material.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';

class GalleryScreen extends StatelessWidget {
  final String salonId;
  const GalleryScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    final items = MockRepository.instance.getGalleryForSalon(salonId);
    
    return Scaffold(
      backgroundColor: AppColors.blushWhite,
      appBar: AppBar(
        title: const Text('Gallery'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: items.isEmpty
          ? const Center(child: Text('No images in gallery.', style: AppTextStyles.bodyLg))
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SafeNetworkImage(
                    imageUrl: it.url,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
