import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state/api_settings.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_data/api_service.dart';
import '../../app_model/models.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= 600;

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  final String salonId;


  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    required this.salonId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  SalonService? _service;
  List<Review> _reviews = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
      final api = ApiService(baseUrl);

      final results = await Future.wait([
        api.getServiceById(widget.serviceId),
        api.getReviewsForSalon(widget.salonId),
      ]);

      if (mounted) {
        setState(() {
          _service = results[0] as SalonService?;
          _reviews = results[1] as List<Review>;
          _loading = false;
          _hasError = _service == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        _loading = false;
        _hasError = true;
      });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            if (_loading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )

            else if (_hasError || _service == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Service not found',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadData,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )

            else
              Expanded(
                child: SingleChildScrollView(
                  child: tablet
                      ? _buildTabletLayout(context)
                      : _buildPhoneLayout(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Phone: centered single column ─────────────────────────────────
  Widget _buildPhoneLayout(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [

        const SizedBox(height: 32),

        _ServiceIconBox(service: _service!),
        const SizedBox(height: 24),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: _ServiceBody(
            service: _service!,
            reviews: _reviews,
            salonId: widget.salonId,
            serviceId: widget.serviceId,
            galleryCrossAxisCount: 3,
          ),
        ),
      ],
    );
  }

  // ── Tablet: icon on left, content on right ────────────────────────
  Widget _buildTabletLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Left: icon + price + meta
          SizedBox(
            width: 220,
            child: Column(
              children: [
                _ServiceIconBox(service: _service!),
                const SizedBox(height: 20),

                // Price
                Text(
                  '\$${_service!.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      _service!.durationLabel.isEmpty
                          ? '30 min'
                          : _service!.durationLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star,
                        color: AppColors.goldMid, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_service!.rating} (${_reviews.length} reviews)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Book Now button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => context
                        .push('/service/${widget.serviceId}/${widget.salonId}'),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 32),
          const VerticalDivider(),
          const SizedBox(width: 32),

          // Right: name, description, gallery, reviews
          Expanded(
            child: _ServiceBody(
              service: _service!,
              reviews: _reviews,
              salonId: widget.salonId,
              serviceId: widget.serviceId,
              galleryCrossAxisCount: 4,
              hidePriceAndMeta: true, // already shown on left panel
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final favorites = context.watch<FavoritesNotifier>();
    final isFav = _service == null
        ? false
        : favorites.isServiceFavorite(_service!.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // Back button
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () =>
            context.canPop() ? context.pop() : context.go('/home'),
          ),

          // Title
          Expanded(
            child: Text(
              _service?.name ?? 'Service Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ⭐ Favorite button (NEW)
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
                onPressed: () {
                  if (_service == null) return;

                  favorites.toggleServiceFav(_service!);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isFav
                            ? 'Removed from favorites 💔'
                            : 'Added to favorites ❤️',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }



}

// ── Icon box ──────────────────────────────────────────────────────────
class _ServiceIconBox extends StatelessWidget {
  final SalonService service;
  const _ServiceIconBox({required this.service});

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(

        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),

      ),

      child: Icon(
        _getServiceIcon(service.name),
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  IconData _getServiceIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('haircut') || n.contains('cut')) return Icons.content_cut;
    if (n.contains('shave') || n.contains('beard') || n.contains('trim')) {
      return Icons.wb_twilight_rounded;
    }
    return Icons.spa_rounded;
  }
}

// ── Main body content (name, meta, price, description, gallery, reviews, CTA)
class _ServiceBody extends StatelessWidget {
  final SalonService service;
  final List<Review> reviews;
  final String salonId;
  final String serviceId;
  final int galleryCrossAxisCount;
  final bool hidePriceAndMeta;

  const _ServiceBody({
    required this.service,
    required this.reviews,
    required this.salonId,
    required this.serviceId,
    required this.galleryCrossAxisCount,
    this.hidePriceAndMeta = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // Name
        Text(
          service.name,
          style: AppTextStyles.heroDisplay.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Duration & Rating (hidden on tablet — shown in left panel)
        if (!hidePriceAndMeta) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                service.durationLabel.isEmpty ? '30 min' : service.durationLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, color: AppColors.goldMid, size: 16),
              const SizedBox(width: 4),
              Text(
                '${service.rating} (${reviews.length} reviews)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Price
          Text(
            '\$${service.price.toStringAsFixed(0)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
        ] else
          const SizedBox(height: 8),

        // Description
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Description',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            service.description.isEmpty
                ? 'Enjoy a premium, tailored experience with professional care and styling.'
                : service.description,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Gallery
        if (service.beforeAfterImages.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Gallery',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: service.beforeAfterImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: galleryCrossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: service.beforeAfterImages[index],
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: Theme.of(context).dividerColor),
                errorWidget: (_, __, ___) => Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],

        // Reviews
        if (reviews.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'User Reviews (${reviews.length})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...reviews.map((r) => _ReviewCard(review: r)),
          const SizedBox(height: 24),
        ],

        // Book Now (phone only — tablet has it in left panel)
        if (!hidePriceAndMeta)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () =>
                    context.push('/service/$serviceId/$salonId'),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: (review.userAvatar.isEmpty)
                    ? Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: review.userAvatar,
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                    errorWidget: (_, __, ___) => Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < review.rating.toInt()
                              ? AppColors.goldMid
                              : Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}