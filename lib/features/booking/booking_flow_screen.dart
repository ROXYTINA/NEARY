
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salon_beauty_app/app_data/api_service.dart';
import 'package:salon_beauty_app/app_state/api_settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../app_data/mock_repository.dart';
import '../../app_model/models.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import 'package:salon_beauty_app/app_widget/common_widget.dart' as cw;

class BookingFlowScreen extends StatefulWidget {
  final String salonId;
  const BookingFlowScreen({super.key, required this.salonId});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0;
  late PageController _pageController;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  Salon? _salon;
  List<SalonService> _services = [];
  List<Stylist> _stylists = [];
  bool _isLoading = true;
  String? _error;

  static const _steps = ['Services', 'Stylist', 'Date & Time', 'Your Info', 'Confirm'];

  @override
  void initState() {
    _pageController = PageController();
    _nameCtrl  = TextEditingController();
    _phoneCtrl = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final api = ApiService(baseUrl);
    try {
      final salon    = await api.getSalonDetails(widget.salonId);
      if (salon == null) {
        if (mounted) setState(() { _error = 'Salon not found'; _isLoading = false; });
        return;
      }
      final services = await api.getServicesForSalon(widget.salonId);
      final stylists = await api.getStylistsForSalon(widget.salonId);
      if (mounted) {
        setState(() { _salon = salon; _services = services; _stylists = stylists; _isLoading = false; });
        context.read<BookingNotifier>().startBooking(salon);
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Connection error: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _salon == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.warmGrey),
              const SizedBox(height: 12),
              Text(_error ?? 'Salon not found', style: AppTextStyles.bodyMd),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final salon   = _salon!;
    final booking = context.watch<BookingNotifier>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(

        children: [
          // ── Custom header ──────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      if (_currentStep > 0) {
                        _previousStep();
                      } else {
                        context.canPop()
                            ? context.pop()
                            : context.go('/salon/${widget.salonId}');
                      }
                    },
                  ),

                  const SizedBox(width: 4),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Appointment',
                          style: AppTextStyles.displaySm,
                          textAlign: TextAlign.center,
                        ),
                        // Text(
                        //   salon.name,
                        //   style: AppTextStyles.bodyMd.copyWith(
                        //     color: AppColors.warmGrey,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Step indicator ─────────────────────────────────────
          _StepIndicator(current: _currentStep, steps: _steps),

          // ── Page content ───────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServicesStep(booking),
                _buildStylistStep(booking),
                _buildDateTimeStep(booking),
                _buildInfoStep(booking),
                _buildConfirmStep(booking),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom nav ─────────────────────────────────────────────
      bottomNavigationBar: _BottomNav(
        currentStep: _currentStep,
        totalSteps: _steps.length,
        booking: booking,
        onBack: _previousStep,
        onNext: () => _currentStep < _steps.length - 1
            ? _nextStep()
            : _confirmBooking(context),
      ),
    );
  }

  // ── Step 1: Services ─────────────────────────────────────────────
  Widget _buildServicesStep(BookingNotifier booking) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      itemCount: _services.length,
      itemBuilder: (_, i) {
        final svc       = _services[i];
        final isSelected = booking.draftServices.any((s) => s.id == svc.id);
        return GestureDetector(
          onTap: () => booking.toggleService(svc),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.rosePrimary.withOpacity(0.07)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.rosePrimary : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.rosePrimary
                        : AppColors.roseLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.content_cut,
                    size: 20,
                    color: isSelected ? Colors.white : AppColors.roseDark,
                  ),
                ),
                const SizedBox(width: 12),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(svc.name, style: AppTextStyles.labelLg),
                      const SizedBox(height: 2),
                      Text(svc.durationLabel,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.warmGrey)),
                    ],
                  ),
                ),
                // Price + check
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${svc.price.toStringAsFixed(0)}',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.rosePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.check_circle_rounded,
                          color: AppColors.rosePrimary, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Step 2: Stylist ──────────────────────────────────────────────
  Widget _buildStylistStep(BookingNotifier booking) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 220,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _stylists.length,
      itemBuilder: (_, i) {
        final st         = _stylists[i];
        final isSelected = booking.draftStylist?.id == st.id;
        return cw.StylistCard(
          stylist: st,
          isSelected: isSelected,
          onTap: () {
            if (isSelected) {
              booking.selectStylist(null);
            } else {
              booking.selectStylist(st);
            }
          },
        );
      },
    );
  }

  // ── Step 3: Date & Time ──────────────────────────────────────────
  Widget _buildDateTimeStep(BookingNotifier booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pick a date', style: AppTextStyles.displaySm),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 90)),
              focusedDay: booking.draftDate ?? DateTime.now(),
              selectedDayPredicate: (day) => isSameDay(day, booking.draftDate),
              onDaySelected: (selected, focused) => booking.selectDate(selected),
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.rosePrimary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.rosePrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle:
                const TextStyle(color: AppColors.rosePrimary),
                weekendTextStyle:
                const TextStyle(color: AppColors.warmGrey),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.labelLg,
                leftChevronIcon: const Icon(Icons.chevron_left,
                    color: AppColors.rosePrimary),
                rightChevronIcon: const Icon(Icons.chevron_right,
                    color: AppColors.rosePrimary),
              ),
            ),
          ),

          if (booking.draftDate != null) ...[
            const SizedBox(height: 24),
            Text('Pick a time', style: AppTextStyles.displaySm),
            const SizedBox(height: 12),
            cw.TimeSlotPicker(
              slots: MockRepository.instance
                  .getAvailableSlots(booking.draftDate!),
              selectedSlot: booking.draftTimeSlot,
              onSlotSelected: (slot) => booking.selectTimeSlot(slot),
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 4: Info ─────────────────────────────────────────────────
  Widget _buildInfoStep(BookingNotifier booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your details', style: AppTextStyles.displaySm),
          const SizedBox(height: 6),
          Text('So we know who to expect.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.warmGrey)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) =>
                booking.updateCustomerInfo(v, _phoneCtrl.text),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (v) =>
                booking.updateCustomerInfo(_nameCtrl.text, v),
          ),
          const SizedBox(height: 24),

          // Mini summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order summary',
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.rosePrimary)),
                const SizedBox(height: 10),
                ...booking.draftServices.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: AppTextStyles.bodyMd),
                      Text('\$${s.price.toStringAsFixed(0)}',
                          style: AppTextStyles.labelMd),
                    ],
                  ),
                )),
                const Divider(color: AppColors.divider),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.charcoal)),
                    Text(
                      '\$${booking.draftTotal.toStringAsFixed(0)}',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.rosePrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 5: Confirm ──────────────────────────────────────────────
  Widget _buildConfirmStep(BookingNotifier booking) {
    final date = booking.draftDate != null
        ? DateFormat('EEEE, MMM d yyyy').format(booking.draftDate!)
        : '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('All set?', style: AppTextStyles.displaySm),
          const SizedBox(height: 4),
          Text('Review your booking before confirming.',
              style:
              AppTextStyles.caption.copyWith(color: AppColors.warmGrey)),
          const SizedBox(height: 20),

          _ConfirmRow(icon: Icons.spa_outlined,
              label: 'Services',
              value: booking.draftServices.map((s) => s.name).join(', ')),
          _ConfirmRow(icon: Icons.person_outline,
              label: 'Stylist',
              value: booking.draftStylist?.name ?? 'Any available'),
          _ConfirmRow(icon: Icons.calendar_today_outlined,
              label: 'Date', value: date),
          _ConfirmRow(icon: Icons.access_time_outlined,
              label: 'Time',
              value: booking.draftTimeSlot ?? '—'),
          _ConfirmRow(icon: Icons.person_pin_outlined,
              label: 'Name',
              value: booking.draftCustomerName.isEmpty
                  ? '—'
                  : booking.draftCustomerName),
          _ConfirmRow(icon: Icons.phone_outlined,
              label: 'Phone',
              value: booking.draftCustomerPhone.isEmpty
                  ? '—'
                  : booking.draftCustomerPhone),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total due', style: AppTextStyles.titleMd),
              Text(
                '\$${booking.draftTotal.toStringAsFixed(0)}',
                style: AppTextStyles.titleMd.copyWith(
                  color: AppColors.rosePrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep++);
  }

  void _previousStep() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentStep--);
  }

  Future<void> _confirmBooking(BuildContext context) async {
    final booking     = context.read<BookingNotifier>();
    final apiSettings = context.read<ApiSettingsNotifier>();

    if (booking.draftServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select at least one service')));
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      return;
    }
    if (booking.draftDate == null || booking.draftTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')));
      setState(() => _currentStep = 2);
      _pageController.jumpToPage(2);
      return;
    }

    final result = await booking.confirmBooking(apiSettings.baseUrl);
    if (result != null && mounted) {
      context.go('/booking-confirmation');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
            Text('Failed to confirm booking. Check your connection.')),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }
}

// ── Step indicator ───────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current;
  final List<String> steps;

  const _StepIndicator({required this.current, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(
            bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            // connector line
            final stepIndex = i ~/ 2;
            final filled = stepIndex < current;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: filled ? AppColors.rosePrimary : AppColors.divider,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final done    = stepIndex < current;
          final active  = stepIndex == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.rosePrimary
                  : active
                  ? AppColors.rosePrimary
                  : AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                '${stepIndex + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : AppColors.softGrey,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Bottom navigation ─────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final BookingNotifier booking;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.booking,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (currentStep > 0) ...[
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
              ),
              child: const Icon(Icons.arrow_back, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isLast ? 'Confirm Booking' : 'Continue'),
                  if (!isLast) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                  if (isLast && booking.draftTotal > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '· \$${booking.draftTotal.toStringAsFixed(0)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Confirm row ───────────────────────────────────────────────────────
class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.rosePrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warmGrey)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.labelMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}