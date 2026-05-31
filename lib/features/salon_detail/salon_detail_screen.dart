import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_data/mock_repository.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

class SalonDetailScreen extends StatefulWidget {
  final String salonId;
  const SalonDetailScreen({super.key, required this.salonId});

  @override
  State<SalonDetailScreen> createState() => _SalonDetailScreenState();
}

class _SalonDetailScreenState extends State<SalonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final salon = MockRepository.instance.getSalonById(widget.salonId);
    final services = MockRepository.instance.getServicesForSalon(widget.salonId);
    final stylists = MockRepository.instance.getStylesForSalon(widget.salonId);
    final reviews = MockRepository.instance.getReviewsForSalon(widget.salonId);
    final gallery = MockRepository.instance.getGalleryForSalon(widget.salonId);
    final favorites = context.watch<FavoritesNotifier>();
    final booking = context.watch<BookingNotifier>();
    final selectedServiceIds = booking.draftServices.map((s) => s.id).toSet();
    final selectedStylistId = booking.draftStylist?.id;

    if (salon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salon')),
        body: const Center(child: Text('Salon not found')),
      );
    }

    final isFav = favorites.isSalonFav(salon.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'salon_${salon.id}',
                    child: SafeNetworkImage(
                      imageUrl: salon.coverImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white),
                onPressed: () => favorites.toggleSalon(salon.id),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salon.name, style: AppTextStyles.heroDisplay),
                      const SizedBox(height: 4),
                      Text(salon.tagline, style: AppTextStyles.caption),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.goldMid, size: 18),
                          const SizedBox(width: 4),
                          Text('${salon.rating} (${salon.reviewCount} reviews)',
                            style: AppTextStyles.labelMd),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: salon.isOpen ? AppColors.success : AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              salon.isOpen ? 'Open' : 'Closed',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.warmGrey),
                          const SizedBox(width: 4),
                          Expanded(child: Text(salon.address, style: AppTextStyles.caption)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 16, color: AppColors.warmGrey),
                          const SizedBox(width: 4),
                          Text(salon.phone, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(thickness: 1),
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Services'),
                    Tab(text: 'Stylists'),
                    Tab(text: 'Reviews'),
                    Tab(text: 'Gallery'),
                  ],
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Services Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  itemBuilder: (_, i) {
                    final svc = services[i];
                    return ServiceCard(
                      service: svc,
                      isSelected: selectedServiceIds.contains(svc.id),
                      onTap: () => context.go('/service/${svc.id}'),
                    );
                  },
                ),
                // Stylists Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: stylists.length,
                  itemBuilder: (_, i) {
                    final st = stylists[i];
                    return Card(
                      child: InkWell(
                        onTap: () => booking.selectStylist(st),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              NetworkAvatar(
                                imageUrl: st.avatar,
                                radius: 34,
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 8),
                              Text(st.name, style: AppTextStyles.labelLg, textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text(st.role, style: AppTextStyles.caption, textAlign: TextAlign.center),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.goldMid),
                                  const SizedBox(width: 4),
                                  Text(st.rating.toStringAsFixed(1), style: AppTextStyles.labelSm),
                                ],
                              ),
                              if (selectedStylistId == st.id) ...[
                                const SizedBox(height: 6),
                                const Icon(Icons.check_circle, color: AppColors.rosePrimary, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Reviews Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: reviews.length,
                  itemBuilder: (_, i) {
                    final r = reviews[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                NetworkAvatar(
                                  imageUrl: r.userAvatar,
                                  radius: 20,
                                  icon: Icons.person,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.userName, style: AppTextStyles.labelLg),
                                      Row(
                                        children: List.generate(5, (index) =>
                                          Icon(Icons.star,
                                            size: 14,
                                            color: index < r.rating.toInt()
                                              ? AppColors.goldMid
                                              : AppColors.divider,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(r.comment, style: AppTextStyles.bodyMd),
                            const SizedBox(height: 8),
                            Text(r.date, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Gallery Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: gallery.length,
                  itemBuilder: (_, i) {
                    final item = gallery[i];
                    return SafeNetworkImage(
                      imageUrl: item.url,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          booking.startBooking(salon);
          context.go('/booking/${salon.id}');
        },
        label: const Text('Book Now'),
        icon: const Icon(Icons.calendar_today),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

