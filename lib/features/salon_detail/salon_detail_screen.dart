
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

import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/Review_card.dart';
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
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Salon not found'),
        ),
      );
    }

    final isFav = favorites.isSalonFav(salon.id);
    final coverUrl = salon.coverImage.isNotEmpty
        ? salon.coverImage
        : (salon.images.isNotEmpty ? salon.images[0] : '');

    return Scaffold(
      extendBodyBehindAppBar: true,

      body: CustomScrollView(
        slivers: [

          // ── Hero AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.rosePrimary,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.pinkAccent : Colors.white,
                      size: 20,
                    ),
                    onPressed: () => favorites.toggleSalon(salon),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image
                  coverUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.roseLight),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.roseLight),
                  )
                      : Container(color: AppColors.roseLight),

                  // Gradient overlay — stronger at bottom for text legibility
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black45,
                          Colors.black87,
                        ],
                        stops: [0.0, 0.4, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // Salon name + tagline pinned to bottom of hero
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salon.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (salon.tagline.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            salon.tagline,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Info strip ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Quick stats row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        // Rating
                        _StatChip(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.goldMid,
                          label:
                          '${salon.rating}  (${salon.reviewCount})',
                        ),
                        const SizedBox(width: 10),

                        // Open/closed
                        _StatChip(
                          icon: Icons.circle,
                          iconColor: salon.isOpen
                              ? AppColors.success
                              : AppColors.error,
                          label: salon.isOpen ? 'Open now' : 'Closed',
                        ),
                        const SizedBox(width: 10),

                        // Price range
                        if (salon.priceRange.isNotEmpty)
                          _StatChip(
                            icon: Icons.attach_money,
                            iconColor: AppColors.goldAccent,
                            label: salon.priceRange,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Address
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 15, color: AppColors.warmGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(salon.address,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Phone
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 15, color: AppColors.warmGrey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(salon.phone,
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Category chips
                  if (salon.categories.isNotEmpty)
                    SizedBox(
                      height: 30,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: salon.categories.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                        itemBuilder: (_, i) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.roseLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            salon.categories[i],
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.rosePrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // Tabs
                  TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    labelStyle: AppTextStyles.labelMd,
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
          ),

          // ── Tab content ─────────────────────────────────────────
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [

                // ── Services ──────────────────────────────────────
                _services.isEmpty
                    ? const Center(child: Text('No services available'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (_, i) {
                    final svc = _services[i];
                    return ServiceCard(
                      service: svc,
                      isSelected: selectedServiceIds.contains(svc.id),
                      onTap: () => context
                          .push('/service/${svc.salonId}/${svc.id}'),
                    );
                  },
                ),

                // ── Stylists ──────────────────────────────────────
                _stylists.isEmpty
                    ? const Center(child: Text('No stylists listed'))
                    : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _stylists.length,
                  itemBuilder: (_, i) {
                    final st = _stylists[i];
                    return StylistCard(
                      stylist: st,
                      isSelected: selectedStylistId == st.id,
                      onTap: () {
                        if (selectedStylistId == st.id) {
                          booking.selectStylist(null);
                        } else {
                          booking.selectStylist(st);
                        }
                      },
                    );
                  },
                ),

                // ── Reviews ───────────────────────────────────────
                _reviews.isEmpty
                    ? const Center(child: Text('No reviews yet'))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (_, i) =>
                      ReviewCard(review: _reviews[i]),
                ),

                // ── Gallery ───────────────────────────────────────
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
                    borderRadius: BorderRadius.circular(12),
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

      // ── Book Now FAB ─────────────────────────────────────────────
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
        backgroundColor: AppColors.rosePrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        label: const Text('Book Now',
            style: TextStyle(fontWeight: FontWeight.w600)),
        icon: const Icon(Icons.calendar_today_rounded, size: 18),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ── Small reusable stat chip ─────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelSm),
        ],
      ),
    );
  }
}