import 'package:flutter/material.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';

class ReviewsScreen extends StatelessWidget {
  final String salonId;
  const ReviewsScreen({super.key, required this.salonId});

  @override
  Widget build(BuildContext context) {
    final reviews = MockRepository.instance.getReviewsForSalon(salonId);
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (_, i) {
          final r = reviews[i];
          return Card(
            child: ListTile(
              leading: NetworkAvatar(
                imageUrl: r.userAvatar,
                radius: 20,
                icon: Icons.person,
              ),
              title: Text(r.userName),
              subtitle: Text(r.comment),
              trailing: Text('${r.rating}'),
            ),
          );
        },
      ),
    );
  }
}

