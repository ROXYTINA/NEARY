import 'package:flutter/material.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';

class GalleryScreen extends StatelessWidget {
  final String salonId;
  const GalleryScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    final items = MockRepository.instance.getGalleryForSalon(salonId);
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final it = items[i];
          return Card(
            clipBehavior: Clip.hardEdge,
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

