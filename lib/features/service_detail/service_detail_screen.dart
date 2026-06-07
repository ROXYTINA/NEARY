import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../app_state/api_settings.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_data/api_service.dart';
import '../../app_model/models.dart';

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
    setState(() { _loading = true; _hasError = false; });
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
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF130F14),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            if (_loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD15170)),
                ),
              )
            else if (_hasError || _service == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white38, size: 48),
                      const SizedBox(height: 12),
                      const Text('Service not found',
                          style: TextStyle(color: Colors.white60, fontSize: 16)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadData,
                        child: const Text('Retry',
                            style: TextStyle(color: Color(0xFFD15170))),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),

                      // Icon box
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF261D24),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Icon(
                          _getServiceIcon(_service!.name),
                          size: 48,
                          color: const Color(0xFFD15170),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Name
                            Text(
                              _service!.name,
                              style: AppTextStyles.heroDisplay.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),

                            // Duration & Rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "⏱️ ${_service!.durationLabel.isEmpty ? '30 min' : _service!.durationLabel}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${_service!.rating} (${_reviews.length} reviews)',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Price
                            Text(
                              '\$${_service!.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFFD15170),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Description
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Description',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _service!.description.isEmpty
                                  ? "Enjoy a premium, tailored experience with professional care and styling."
                                  : _service!.description,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 15, height: 1.5),
                            ),
                            const SizedBox(height: 28),

                            // Gallery
                            if (_service!.beforeAfterImages.isNotEmpty) ...[
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Gallery',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _service!.beforeAfterImages.length,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemBuilder: (context, index) => ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: _service!.beforeAfterImages[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: AppColors.divider),
                                    errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image,
                                        color: Colors.white24),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],

                            // Reviews
                            if (_reviews.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'User Reviews (${_reviews.length})',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._reviews.map((r) => _ReviewCard(review: r)),
                              const SizedBox(height: 24),
                            ],

                            // Book Now
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8C3A52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () =>
                                      context.go('/booking/${widget.salonId}'),
                                  child: const Text(
                                    'Book Now',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
          Text(
            _service?.name ?? 'Service Details',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
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

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF261D24),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.roseMid,
                child: (review.userAvatar == null || review.userAvatar!.isEmpty)
                    ? Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                )
                    : ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: review.userAvatar!,
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                    errorWidget: (context, url, error) => Text(
                      review.userName.isNotEmpty
                          ? review.userName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(Icons.star,
                            size: 14,
                            color: i < review.rating.toInt()
                                ? AppColors.goldMid
                                : Colors.white24),
                      ),
                    ),
                  ],
                ),
              ),
              Text(review.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment!,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14)),
          ],
        ],
      ),
    );
  }
}