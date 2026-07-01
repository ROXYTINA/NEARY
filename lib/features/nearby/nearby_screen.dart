import 'package:flutter/material.dart';
import '../../app_data/mock_repository.dart';
import '../../app_widget/common_widget.dart';

class NearbyScreen extends StatelessWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
	final salons = MockRepository.instance.getNearbySalons();
	return Scaffold(
	  appBar: AppBar(title: const Text('Nearby')),
	  body: ListView.builder(
		padding: const EdgeInsets.all(16),
		itemCount: salons.length,
		itemBuilder: (_, i) {
		  final s = salons[i];
		  return SalonCard(
			salon: s,
			isFav: false,
			onFav: () {},
			onTap: () {},
		  );
		},
	  ),
	);
  }
}


