import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../app_state/notifiers.dart';
import '../../app_state/api_settings.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_model/models.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
      context.read<BookingNotifier>().load(baseUrl);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final booking = context.watch<BookingNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(booking.upcomingBookings, upcoming: true),
          _buildList(booking.pastBookings,     upcoming: false),
        ],
      ),
    );
  }

  Widget _buildList(List<Booking> bookings, {required bool upcoming}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              upcoming ? Icons.calendar_today_outlined : Icons.history,
              size: 64,
              color: AppColors.softGrey,
            ),
            const SizedBox(height: 16),
            Text(
              upcoming ? 'No upcoming bookings' : 'No past bookings',
              style: AppTextStyles.titleMd,
            ),
            const SizedBox(height: 8),
            Text(
              upcoming ? 'Book a salon to get started' : 'Your completed bookings will appear here',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            if (upcoming) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Explore Salons'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (_, i) => _BookingCard(
        booking: bookings[i],
        upcoming: upcoming,
        onCancel: upcoming
            ? () => _confirmCancel(bookings[i])
            : null,
        onRebook: !upcoming
            ? () => context.go('/booking/${bookings[i].salonId}')
            : null,
      ),
    );
  }

  void _confirmCancel(Booking booking) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
            'Cancel your appointment at ${booking.salonName} on ${_formatDate(booking.date)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingNotifier>().cancelBooking(booking.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);
}

// ── Booking Card ───────────────────────────────────────────────
class _BookingCard extends StatefulWidget {
  final Booking booking;
  final bool upcoming;
  final VoidCallback? onCancel;
  final VoidCallback? onRebook;

  const _BookingCard({
    required this.booking,
    required this.upcoming,
    this.onCancel,
    this.onRebook,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _expanded = false;
  final _couponCtrl = TextEditingController();
  String? _appliedCoupon;
  double _discountPercent = 0;
  bool _couponLoading = false;
  String? _couponError;

  @override
  void dispose() {
    _couponCtrl.dispose();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.booking.status) {
      case 'upcoming':  return AppColors.success;
      case 'past':      return AppColors.warmGrey;
      case 'cancelled': return AppColors.error;
      default:          return AppColors.warmGrey;
    }
  }

  String get _statusLabel {
    switch (widget.booking.status) {
      case 'upcoming':  return 'Upcoming';
      case 'past':      return 'Completed';
      case 'cancelled': return 'Cancelled';
      default:          return widget.booking.status;
    }
  }

  double get _discountedTotal =>
      widget.booking.totalPrice * (1 - _discountPercent / 100);

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() { _couponLoading = true; _couponError = null; });

    // Simulate API call — replace with real endpoint
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock coupon validation — wire to your backend
    const validCoupons = {
      'SUMMER20': 20.0,
      'NEWCLIENT15': 15.0,
      'WEEKEND25': 25.0,
      'BRIDAL2024': 10.0,
    };

    if (mounted) {
      if (validCoupons.containsKey(code)) {
        setState(() {
          _appliedCoupon    = code;
          _discountPercent  = validCoupons[code]!;
          _couponLoading    = false;
          _couponError      = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_discountPercent.toInt()}% discount applied!'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        setState(() {
          _couponLoading = false;
          _couponError   = 'Invalid or expired coupon code';
        });
      }
    }
  }

  void _removeCoupon() {
    setState(() {
      _appliedCoupon   = null;
      _discountPercent = 0;
      _couponError     = null;
      _couponCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final b = widget.booking;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Salon initial avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.roseLight,
                        child: Text(
                          b.salonName.isNotEmpty
                              ? b.salonName[0].toUpperCase()
                              : 'S',
                          style: AppTextStyles.titleMd.copyWith(
                              color: AppColors.rosePrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.salonName,
                                style: AppTextStyles.labelLg),
                            const SizedBox(height: 2),
                            Text(
                              b.serviceNames.join(', '),
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel,
                          style: AppTextStyles.labelSm.copyWith(
                              color: _statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date / Time / Price row
                  Row(
                    children: [
                      _infoChip(Icons.calendar_today_outlined,
                          DateFormat('MMM d, yyyy').format(b.date)),
                      const SizedBox(width: 8),
                      _infoChip(Icons.access_time, b.timeSlot),
                      const Spacer(),
                      Text(
                        '\$${_discountedTotal.toStringAsFixed(0)}',
                        style: AppTextStyles.titleMd.copyWith(
                            color: scheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded details ─────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confirmation code
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          size: 16, color: AppColors.warmGrey),
                      const SizedBox(width: 6),
                      Text('Confirmation: ',
                          style: AppTextStyles.caption),
                      Text(
                        b.confirmationCode,
                        style: AppTextStyles.labelLg.copyWith(
                            color: scheme.primary,
                            letterSpacing: 2),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: b.confirmationCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Code copied!')),
                          );
                        },
                        child: const Icon(Icons.copy,
                            size: 14, color: AppColors.warmGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Services breakdown
                  Text('Services', style: AppTextStyles.labelLg),
                  const SizedBox(height: 6),
                  ...b.serviceNames.map((name) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.circle,
                            size: 6, color: AppColors.rosePrimary),
                        const SizedBox(width: 8),
                        Text(name, style: AppTextStyles.bodyMd),
                      ],
                    ),
                  )),
                  const SizedBox(height: 12),

                  // Stylist
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.warmGrey),
                      const SizedBox(width: 6),
                      Text('Stylist: ', style: AppTextStyles.caption),
                      Text(b.stylistName,
                          style: AppTextStyles.bodyMd),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Customer info
                  Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 16, color: AppColors.warmGrey),
                      const SizedBox(width: 6),
                      Text(b.customerPhone,
                          style: AppTextStyles.bodyMd),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Coupon section (upcoming only) ──────────
                  if (widget.upcoming &&
                      b.status == 'upcoming') ...[
                    Text('Apply Coupon',
                        style: AppTextStyles.labelLg),
                    const SizedBox(height: 8),
                    if (_appliedCoupon != null)
                    // Applied coupon chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.success, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _appliedCoupon!,
                                    style: AppTextStyles.labelLg
                                        .copyWith(
                                        color: AppColors.success,
                                        letterSpacing: 1.5),
                                  ),
                                  Text(
                                    '${_discountPercent.toInt()}% off — saves \$${(widget.booking.totalPrice * _discountPercent / 100).toStringAsFixed(0)}',
                                    style: AppTextStyles.caption
                                        .copyWith(
                                        color: AppColors.success),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: AppColors.warmGrey),
                              onPressed: _removeCoupon,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _couponCtrl,
                              textCapitalization:
                              TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter coupon code',
                                prefixIcon: const Icon(
                                    Icons.local_offer_outlined),
                                errorText: _couponError,
                                suffixIcon: _couponCtrl.text.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _couponCtrl.clear();
                                    setState(
                                            () => _couponError = null);
                                  },
                                )
                                    : null,
                              ),
                              onChanged: (_) =>
                                  setState(() => _couponError = null),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _couponLoading
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          )
                              : ElevatedButton(
                            onPressed: _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],

                    // Price breakdown
                    if (_appliedCoupon != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style: AppTextStyles.bodyMd),
                                Text(
                                    '\$${b.totalPrice.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodyMd),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Discount (${_discountPercent.toInt()}%)',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success)),
                                Text(
                                    '-\$${(b.totalPrice * _discountPercent / 100).toStringAsFixed(0)}',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style: AppTextStyles.labelLg),
                                Text(
                                  '\$${_discountedTotal.toStringAsFixed(0)}',
                                  style: AppTextStyles.titleMd.copyWith(
                                      color: scheme.primary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],

                  // ── Action buttons ───────────────────────────
                  Row(
                    children: [
                      if (widget.onRebook != null)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onRebook,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Book Again'),
                          ),
                        ),
                      if (widget.onCancel != null) ...[
                        if (widget.onRebook != null)
                          const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onCancel,
                            icon: Icon(Icons.cancel_outlined,
                                size: 16, color: AppColors.error),
                            label: Text('Cancel',
                                style: TextStyle(
                                    color: AppColors.error)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.error),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],

          // ── Expand toggle hint ───────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded ? 'Show less' : 'Show details',
                    style: AppTextStyles.caption
                        .copyWith(color: scheme.primary),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: scheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.warmGrey),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}