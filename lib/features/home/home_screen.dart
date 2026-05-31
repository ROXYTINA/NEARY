import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app_data/mock_repository.dart';
import '../../app_model/models.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/common_widget.dart';

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

  final _categories = ['All', 'Hair', 'Nails', 'Makeup', 'Spa', 'Bridal'];
  final _repo = MockRepository.instance;

  final _bannerImages = [
    'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=900',
    'https://images.unsplash.com/photo-1519741347686-c1e0aadf4611?w=900',
    'https://images.unsplash.com/photo-1600334129128-685c5582fd35?w=900',
    'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=900',
  ];

  final _bannerTitles = [
    'Your Beauty Journey\nStarts Here',
    'Find Your Perfect\nBridal Look',
    'Relax & Rejuvenate\nWith Our Spas',
    'Makeup Artistry\nAt Its Finest',
  ];

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesNotifier>();
    final salons = _searchQuery.isNotEmpty
        ? _repo.searchSalons(_searchQuery)
        : _repo.getSalonsByCategory(_selectedCategory);
    final promos = _repo.getAllPromotions().take(3).toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            title: Row(
              children: [
                Text('Salon',
                    style: AppTextStyles.displaySm
                        .copyWith(color: AppColors.rosePrimary)),
                Text(' & Beauty', style: AppTextStyles.displaySm),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: () => context.go('/my-bookings'),
                tooltip: 'My Bookings',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Carousel
                _buildCarousel(),
                const SizedBox(height: 20),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search salons, services...',
                      prefixIcon: const Icon(Icons.search_outlined,
                          color: AppColors.warmGrey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.warmGrey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category chips
                if (_searchQuery.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Categories', style: AppTextStyles.displaySm),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryChips(),
                  const SizedBox(height: 20),
                ],

                // Promotions strip
                if (_searchQuery.isEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SectionHeader(
                      title: 'Current Offers',
                      subtitle: 'Limited time deals',
                      onSeeAll: () => context.go('/promotions'),
                    ),
                  ),
                  _buildPromoStrip(promos),
                  const SizedBox(height: 8),
                ],

                // Featured / Search Results
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SectionHeader(
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

                // Salon list
                if (salons.isEmpty)
                  const EmptyState(
                    icon: Icons.search_off,
                    title: 'No salons found',
                    message: 'Try a different search or category.',
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: salons
                          .map((s) => SalonCard(
                        salon: s,
                        isFav: favs.isSalonFav(s.id),
                        onFav: () => favs.toggleSalon(s.id),
                        onTap: () => context.push('/salon/${s.id}'),
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

  Widget _buildCarousel() {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _bannerImages.length,
          options: CarouselOptions(
            height: 220,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
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
                placeholder: (_, __) => Container(
                  color: AppColors.roseLight,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.roseLight,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x99000000), Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 24,
                child: Text(
                  _bannerTitles[i],
                  style: AppTextStyles.displaySm.copyWith(
                      color: Colors.white, fontSize: 28),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSmoothIndicator(
          activeIndex: _carouselIndex,
          count: _bannerImages.length,
          effect: ExpandingDotsEffect(
            dotColor: AppColors.roseMid,
            activeDotColor: AppColors.rosePrimary,
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.rosePrimary
                          : AppColors.roseLight,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                          color: AppColors.rosePrimary, width: 2)
                          : null,
                    ),
                    child: Icon(
                      _categoryIcon(cat),
                      color: isSelected
                          ? Colors.white
                          : AppColors.roseDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    cat,
                    style: AppTextStyles.labelSm.copyWith(
                      color: isSelected
                          ? AppColors.rosePrimary
                          : AppColors.warmGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoStrip(List<Promotion> promos) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: promos.length,
        itemBuilder: (_, i) {
          final p = promos[i];
          return GestureDetector(
            onTap: () => context.go('/promotions'),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.rosePrimary.withValues(alpha: 0.8),
                    AppColors.goldAccent.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: p.image,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      color: Colors.black38,
                      colorBlendMode: BlendMode.darken,
                      placeholder: (_, __) => Container(
                        color: AppColors.roseLight,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.roseLight,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldMid,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${p.discountPercent}% OFF',
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.charcoal),
                          ),
                        ),
                        Text(
                          p.title,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Hair':   return Icons.content_cut;
      case 'Nails':  return Icons.back_hand_outlined;
      case 'Makeup': return Icons.face_retouching_natural;
      case 'Spa':    return Icons.spa_outlined;
      case 'Bridal': return Icons.favorite_outline;
      default:       return Icons.auto_awesome;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}