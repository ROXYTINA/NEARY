import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_data/api_service.dart';
import '../../app_model/models.dart';
import '../../app_state/api_settings.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  String _selectedCategory = 'All';
  List<Promotion> _promos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final results = await ApiService(baseUrl).getPromotions();
    if (mounted) setState(() { _promos = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'All'
        ? _promos
        : _promos.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Promotions & Coupons',
          style: AppTextStyles.displaySm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Hair', 'Nails', 'Makeup', 'Spa',
                  'Bridal', 'General']
                    .map((cat) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _selectedCategory == cat,
                    label: Text(cat),
                    onSelected: (_) => setState(
                            () => _selectedCategory = cat),
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
              icon: Icons.local_offer_outlined,
              title: 'No promotions',
              message: 'Check back later for great deals',
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final promo = filtered[i];
                return PromotionCard(
                  promo: promo,
                  onCopy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Code ${promo.code} copied!')),
                    );
                  },
                  onUse: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Redeem at salon')),
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