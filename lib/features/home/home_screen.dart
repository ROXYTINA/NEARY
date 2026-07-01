import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app_data/api_service.dart';
import '../../app_model/models.dart';
import '../../app_state/notifiers.dart';
import '../../app_state/api_settings.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

// ── Responsive helper ─────────────────────────────────────────────────
bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _carouselIndex = 0;

  List<Salon>? _remoteSalons;
  List<Promotion> _promos = [];
  bool _isLoading = false;
  String? _apiError;

  final _categories = ['All', 'Hair', 'Nails', 'Makeup', 'Spa', 'Bridal'];

  final _bannerImages = [
    'https://i.pinimg.com/736x/30/28/c8/3028c897d22592831a12a2647aa6537d.jpg',
    'https://i.pinimg.com/1200x/ba/27/cf/ba27cfbb96554c85e7f8535e4641b042.jpg',
    'https://i.pinimg.com/736x/c6/82/30/c68230227a85566457d6d43b1d8ca148.jpg',
    'https://i.pinimg.com/736x/51/cb/9e/51cb9e1831e9469e63cb1ee9f1aa1094.jpg',
  ];

  final _bannerTitles = [
    'Look Good,\nFeel Amazing',
    'Unwind at\nOur Spas',
    'Makeup Artistry\nAt Its Finest',
    'Relax &\nRejuvenate',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRemoteSalons();
      _fetchPromos();
    });
  }

  Future<void> _fetchPromos() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final results = await ApiService(baseUrl).getPromotions();
    if (mounted) setState(() => _promos = results);
  }

  Future<void> _fetchRemoteSalons() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    setState(() {
      _isLoading = true;
      _apiError = null;
    });
    final results = await ApiService(baseUrl).getSalons();
    if (mounted) {
      setState(() {
        _remoteSalons = results.isNotEmpty ? results : null;
        _apiError = results.isEmpty ? 'Could not load salons' : null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    final hPad = tablet ? 24.0 : 16.0;
    final favs = context.watch<FavoritesNotifier>();
    final sourceSalons = _remoteSalons ?? [];
    final salons = _searchQuery.isNotEmpty
        ? sourceSalons
        .where((s) =>
        s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList()
        : _selectedCategory == 'All'
        ? sourceSalons
        : sourceSalons
        .where((s) => s.categories.contains(_selectedCategory))
        .toList();

    final promos = _promos.take(3).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // ── App Bar ─────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            titleSpacing: hPad,
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Neary',
                    style: AppTextStyles.displaySm.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: AppTextStyles.displaySm.copyWith(
                      color: AppColors.goldAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined, size: 22),
                onPressed: () => context.go('/my-bookings'),
                tooltip: 'My Bookings',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                onPressed: () => context.go('/settings'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Hero carousel ──────────────────────────────────
                _buildCarousel(tablet),
                const SizedBox(height: 24),

                // ── Search bar ─────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search salons or services...',
                      prefixIcon: Icon(
                        Icons.search_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Categories ─────────────────────────────────────
                if (_searchQuery.isEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: const Text('Browse by Category',
                        style: AppTextStyles.displaySm),
                  ),
                  const SizedBox(height: 14),
                  _buildCategoryChips(tablet),
                  const SizedBox(height: 24),
                ],

                // ── Promotions ─────────────────────────────────────
                if (_searchQuery.isEmpty && promos.isNotEmpty) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _SectionHeader(
                      title: 'Current Offers',
                      subtitle: 'Limited time deals',
                      onSeeAll: () => context.go('/promotions'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPromoStrip(promos, tablet),
                  const SizedBox(height: 24),
                ],

                // ── Salon list header ──────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: _SectionHeader(
                    title: _searchQuery.isNotEmpty
                        ? 'Search Results'
                        : _selectedCategory == 'All'
                        ? 'Top Rated Near You'
                        : '$_selectedCategory Salons',
                    subtitle: _searchQuery.isNotEmpty
                        ? '${salons.length} salons found'
                        : 'Sorted by rating',
                    onSeeAll: () => context.go('/nearby'),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Salon list / grid ──────────────────────────────
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_apiError != null && salons.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: hPad, vertical: 32),
                    child: _ErrorCard(
                      message: _apiError!,
                      onRetry: _fetchRemoteSalons,
                    ),
                  )
                else if (salons.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No salons found',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),

                      // Tablet: 2-column grid; Phone: single column list

                      child: tablet
                          ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 0,
                          childAspectRatio: 1.70,
                        ),
                        itemCount: salons.length,
                        itemBuilder: (_, i) => SalonCard(
                          salon: salons[i],
                          isFav: favs.isSalonFav(salons[i].id),
                          onFav: () => favs.toggleSalon(salons[i]),
                          onTap: () =>
                              context.push('/salon/${salons[i].id}'),
                        ),
                      )
                          : Column(
                        children: salons
                            .map((s) => SalonCard(
                          salon: s,
                          isFav: favs.isSalonFav(s.id),
                          onFav: () => favs.toggleSalon(s),
                          onTap: () =>
                              context.push('/salon/${s.id}'),
                        ))
                            .toList(),
                      ),

                    ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carousel ───────────────────────────────────────────────────────
  Widget _buildCarousel(bool tablet) {
    final carouselHeight = tablet ? 300.0 : 210.0;
    final textSize = tablet ? 32.0 : 26.0;

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _bannerImages.length,
          options: CarouselOptions(
            height: carouselHeight,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            onPageChanged: (i, _) => setState(() => _carouselIndex = i),
          ),
          itemBuilder: (_, i, __) => Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: _bannerImages[i],
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: AppColors.roseLight),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.roseLight),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xCC000000), Colors.transparent],
                    stops: [0.0, 0.65],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0x88000000), Colors.transparent],
                    stops: [0.0, 0.5],
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: tablet ? 40 : 24,
                right: tablet ? 200 : 120,
                child: Text(
                  _bannerTitles[i],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _carouselIndex,
          count: _bannerImages.length,
          effect: ExpandingDotsEffect(
            dotColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            activeDotColor: Theme.of(context).colorScheme.primary,
            dotHeight: 5,
            dotWidth: 5,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  // ── Category chips ─────────────────────────────────────────────────
  Widget _buildCategoryChips(bool tablet) {
    final chipSize = tablet ? 68.0 : 54.0;
    final iconSize = tablet ? 28.0 : 22.0;

    final chips = _categories.map((cat) {
      final isSelected = cat == _selectedCategory;
      return GestureDetector(
        onTap: () => setState(() => _selectedCategory = cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: chipSize,
                height: chipSize,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                ),
                child: Icon(
                  _categoryIcon(cat),
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: iconSize,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                cat,
                style: TextStyle(
                  fontSize: tablet ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    if (tablet) {
      // Spread evenly across full width on tablet
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: chips,
        ),
      );
    }

    // Scrollable list on phone
    return SizedBox(
      height: 88,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: chips
            .map((c) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: c,
        ))
            .toList(),
      ),
    );
  }

  // ── Promo strip ────────────────────────────────────────────────────
  Widget _buildPromoStrip(List<Promotion> promos, bool tablet) {
    final cardWidth = tablet ? 300.0 : 230.0;
    final stripHeight = tablet ? 140.0 : 110.0;

    return SizedBox(
      height: stripHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: tablet ? 24 : 16),
        itemCount: promos.length,
        itemBuilder: (_, i) {
          final p = promos[i];
          return GestureDetector(
            onTap: () => context.go('/promotions'),
            child: Container(
              width: cardWidth,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [AppColors.rosePrimary, AppColors.goldAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: p.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      color: Colors.black45,
                      colorBlendMode: BlendMode.darken,
                      placeholder: (_, __) =>
                          Container(color: AppColors.roseDark),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.roseDark),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.goldMid,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${p.discountPercent}% OFF',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                          Text(
                            p.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: tablet ? 15 : 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Hair':
        return Icons.content_cut;
      case 'Nails':
        return Icons.back_hand_outlined;
      case 'Makeup':
        return Icons.face_retouching_natural;
      case 'Spa':
        return Icons.spa_outlined;
      case 'Bridal':
        return Icons.favorite_outline;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ── Section header ─────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.displaySm),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: AppTextStyles.labelMd.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Error card ─────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 36, color: AppColors.error),
          const SizedBox(height: 10),
          Text(
            'Couldn\'t load salons',
            style: AppTextStyles.labelLg.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(
            'Check your connection and try again.',
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}