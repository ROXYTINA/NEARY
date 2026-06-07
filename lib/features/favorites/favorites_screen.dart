import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}


class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);

    final favs = context.watch<FavoritesNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTextStyles.displaySm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),

      body: Column(
        children: [
          TabBar(controller: _tabController, tabs: const [Tab(text: 'Salons'), Tab(text: 'Services')]),
          Expanded(
            child: TabBarView(
              controller: _tabController,

              children: [

                // Salons Tab
                favs.favSalons.isEmpty
                    ? EmptyState(
                  icon: Icons.favorite_outline,
                  title: 'No saved salons',
                  message: 'Salons you like will appear here',
                  action: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Explore Salons'),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favs.favSalons.length,
                  itemBuilder: (_, i) {
                    final salon = favs.favSalons[i];
                    return SalonCard(
                      salon: salon,
                      isFav: true,
                      onFav: () => favs.removeSalon(salon.id),
                      onTap: () => context.go('/salon/${salon.id}'),
                    );
                  },
                ),

                // Services Tab
                favs.favServices.isEmpty
                    ? EmptyState(
                  icon: Icons.favorite_outline,
                  title: 'No saved services',
                  message: 'Services you like will appear here',
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favs.favServices.length,
                  itemBuilder: (_, i) {
                    final svc = favs.favServices[i];
                    return ServiceCard(
                      service: svc,
                      isSelected: false,
                      onTap: () => context.go('/service/${svc.id}'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

