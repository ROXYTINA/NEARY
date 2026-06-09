import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salon_beauty_app/app_data/api_service.dart';
import 'package:salon_beauty_app/app_model/salon.dart';
import 'package:salon_beauty_app/app_model/service.dart';
import 'package:salon_beauty_app/app_model/stylist.dart';
import 'package:salon_beauty_app/app_model/review.dart';
import 'package:salon_beauty_app/app_state/api_settings.dart';
import 'package:url_launcher/url_launcher.dart';


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

class _SalonDetailScreenState extends State<SalonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Salon? _remoteSalon;
  List<SalonService> _services = [];
  List<Stylist> _stylists = [];
  List<Review> _reviews = [];
  List<String> _galleryImages = [];
  bool _isLoading = true;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
      final api = ApiService(baseUrl);

      final result   = await api.getSalonDetails(widget.salonId);
      final services = await api.getServicesForSalon(widget.salonId);
      final stylists = await api.getStylistsForSalon(widget.salonId);
      final reviews  = await api.getReviewsForSalon(widget.salonId);

      if (mounted) {
        setState(() {
          _remoteSalon   = result;
          _services      = services;
          _stylists      = stylists;
          _reviews       = reviews;
          _galleryImages = result?.images ?? [];
          _isLoading     = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salon = _remoteSalon;
    final favorites = context.watch<FavoritesNotifier>();
    final booking = context.watch<BookingNotifier>();
    final selectedServiceIds = booking.draftServices.map((s) => s.id).toSet();
    final selectedStylistId = booking.draftStylist?.id;

    if (salon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Salon')),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Salon not found'),
        ),
      );
    }

    final isFav = favorites.isSalonFav(salon.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // ── Hero AppBar ─────────────────────────────────────────

          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: salon.images.isNotEmpty
                        ? salon.images.length
                        : 1,
                    itemBuilder: (context, index) {
                      final image = salon.images.isNotEmpty
                          ? salon.images[index]
                          : salon.coverImage;

                      return CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                      );
                    },
                  ),

                  // dark gradient overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: () => favorites.toggleSalon(salon),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Salon Info ─────────────────────────────────────
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
                          const Icon(Icons.star,
                              color: AppColors.goldMid, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${salon.rating} (${salon.reviewCount} reviews)',
                            style: AppTextStyles.labelMd,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: salon.isOpen
                                  ? AppColors.success
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              salon.isOpen ? 'Open' : 'Closed',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${salon.lat},${salon.lng}',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Could not launch Google Maps'),
                                ),
                              );
                            }
                          }
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 16, color: AppColors.warmGrey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  salon.address,
                                  style: AppTextStyles.caption.copyWith(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined,
                              size: 16, color: AppColors.warmGrey),
                          const SizedBox(width: 4),
                          Text(salon.phone, style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(thickness: 1),

                // ── Tabs ───────────────────────────────────────────
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

          // ── Tab Content ──────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Services Tab
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (_, i) {
                    final svc = _services[i];
                    return ServiceCard(
                      service: svc,
                      isSelected: selectedServiceIds.contains(svc.id),
                      onTap: () => context.push('/service/${svc.salonId}/${svc.id}'),
                    );
                  },
                ),

                // Stylists Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _stylists.length,
                  itemBuilder: (_, i) {
                    final st = _stylists[i];
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
                              Text(st.name,
                                  style: AppTextStyles.labelLg,
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text(st.role,
                                  style: AppTextStyles.caption,
                                  textAlign: TextAlign.center),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star,
                                      size: 14, color: AppColors.goldMid),
                                  const SizedBox(width: 4),
                                  Text(st.rating.toStringAsFixed(1),
                                      style: AppTextStyles.labelSm),
                                ],
                              ),
                              if (selectedStylistId == st.id) ...[
                                const SizedBox(height: 6),
                                const Icon(Icons.check_circle,
                                    color: AppColors.rosePrimary, size: 20),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Reviews Tab
                _reviews.isEmpty
                    ? const Center(child: Text('No reviews yet'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (_, i) {
                    final r = _reviews[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                              Text(r.userName,
                              style: AppTextStyles.labelLg),
                                Row(
                                  children: List.generate(
                                    5,
                                        (index) => Icon(
                                      Icons.star,
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
                    const SizedBox(height: 4),
                    Text(r.date,
                    style: AppTextStyles.caption.copyWith(
                    color: AppColors.warmGrey)),
                    ],
                    ),
                    ),
                    );
                  },
                ),

                // Gallery Tab
                _galleryImages.isEmpty
                    ? const Center(child: Text('No gallery images'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _galleryImages.length,
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SafeNetworkImage(
                      imageUrl: _galleryImages[i],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final auth = context.read<AuthNotifier>();
          if (!auth.isLoggedIn) {
            context.go('/auth?redirect=/booking/${salon.id}');
          } else {
            booking.startBooking(salon);
            context.go('/booking/${salon.id}');
          }
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