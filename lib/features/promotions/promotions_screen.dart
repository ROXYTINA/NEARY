import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_data/mock_repository.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final repo = MockRepository.instance;
    final promos = _selectedCategory == 'All'
        ? repo.getAllPromotions()
        : repo.getPromotionsByCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('Promotions & Coupons')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Hair', 'Nails', 'Makeup', 'Spa', 'Bridal', 'General']
                    .map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == cat,
                    label: Text(cat),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: promos.isEmpty
                ? EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No promotions',
              message: 'Check back later for great deals',
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: promos.length,
              itemBuilder: (_, i) {
                final promo = promos[i];
                return PromotionCard(
                  promo: promo,
                  onCopy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Code ${promo.code} copied!')),
                    );
                  },
                  onUse: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Redeem at salon')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

