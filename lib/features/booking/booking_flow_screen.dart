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
  List<String> _availableSlots = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    _pageController = PageController();
    _nameCtrl  = TextEditingController();
    _phoneCtrl = TextEditingController();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final api = ApiService(baseUrl);

    try {
      // 1. Try Salon Details
      Salon? salon = await api.getSalonDetails(widget.salonId);

      if (salon == null) {
        if (mounted) setState(() { _error = 'Salon not found on server'; _isLoading = false; });
        return;
      }

      // 2. Try Services & Stylists
      List<SalonService> services = await api.getServicesForSalon(widget.salonId);
      List<Stylist> stylists = await api.getStylistsForSalon(widget.salonId);

      if (mounted) {
        setState(() {
          _salon = salon;
          _services = services;
          _stylists = stylists;
          _isLoading = false;
        });
        
        // Init draft
        final booking = context.read<BookingNotifier>();
        booking.startBooking(salon);
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Server connection error: $e'; _isLoading = false; });
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final api = ApiService(baseUrl);
    
    final slots = await api.getAvailableSlots(widget.salonId, date);
    if (mounted) {
      setState(() {
        _availableSlots = slots;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null || _salon == null) return Scaffold(body: Center(child: Text(_error ?? 'Salon not found')));

    final salon = _salon!;
    final booking = context.watch<BookingNotifier>();

    final steps = [
      'Services',
      'Stylist',
      'Date & Time',
      'Your Info',
      'Confirm',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/salon/${widget.salonId}');
              }
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(salon.name, style: AppTextStyles.titleMd),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: steps.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _currentStep >= i ? AppColors.rosePrimary : AppColors.divider,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          steps[i],
                          style: TextStyle(
                            color: _currentStep >= i ? Colors.white : AppColors.softGrey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServicesStep(_services, booking),
                _buildStylistStep(_stylists, booking),
                _buildDateTimeStep(booking),
                _buildInfoStep(booking),
                _buildConfirmStep(booking),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _currentStep < 4 ? _nextStep : () => _confirmBooking(context),
                child: Text(_currentStep < 4 ? 'Next' : 'Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesStep(List<SalonService> services, BookingNotifier booking) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (_, i) {
        final svc = services[i];
        final isSelected = booking.draftServices.any((s) => s.id == svc.id);
        return Card(
          color: isSelected ? AppColors.roseLight : null,
          child: InkWell(
            onTap: () => booking.toggleService(svc),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(svc.name, style: AppTextStyles.labelLg),
                        Text(svc.durationLabel, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${svc.price}', style: AppTextStyles.titleMd),
                      if (isSelected) const Icon(Icons.check_circle, color: AppColors.rosePrimary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStylistStep(List<Stylist> stylists, BookingNotifier booking) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: stylists.length,
      itemBuilder: (_, i) {
        final st = stylists[i];
        final isSelected = booking.draftStylist?.id == st.id;
        return cw.StylistCard(
          stylist: st,
          isSelected: isSelected,
          onTap: () => booking.selectStylist(st),
        );
      },
    );
  }

  Widget _buildDateTimeStep(BookingNotifier booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Date', style: AppTextStyles.titleMd),
          const SizedBox(height: 12),
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: booking.draftDate ?? DateTime.now(),
            selectedDayPredicate: (day) => isSameDay(day, booking.draftDate),
            onDaySelected: (selectedDay, focusedDay) {
              booking.selectDate(selectedDay);
            },
          ),
          if (booking.draftDate != null) ...[
            const SizedBox(height: 20),
            Text('Select Time', style: AppTextStyles.titleMd),
            const SizedBox(height: 12),
            cw.TimeSlotPicker(
              slots: MockRepository.instance.getAvailableSlots(booking.draftDate!),
              selectedSlot: booking.draftTimeSlot,
              onSlotSelected: (slot) => booking.selectTimeSlot(slot),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoStep(BookingNotifier booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: (v) => booking.updateCustomerInfo(v, _phoneCtrl.text),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(
              labelText: 'Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (v) => booking.updateCustomerInfo(_nameCtrl.text, v),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Summary', style: AppTextStyles.titleMd),
                  const SizedBox(height: 8),
                  ...booking.draftServices.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.name),
                        Text('\$${s.price.toStringAsFixed(0)}'),
                      ],
                    ),
                  )),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '\$${booking.draftTotal.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmStep(BookingNotifier booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Booking Details', style: AppTextStyles.titleMd),
                  const SizedBox(height: 12),
                  ...booking.draftServices.map((s) => Text('• ${s.name} (${s.durationLabel})')),
                  const SizedBox(height: 8),
                  Text('Stylist: ${booking.draftStylist?.name ?? 'Any'}'),
                  Text('Date: ${booking.draftDate != null ? DateFormat('MMM d, yyyy').format(booking.draftDate!) : 'Not selected'}'),
                  Text('Time: ${booking.draftTimeSlot ?? 'Not selected'}'),
                  Text('Name: ${booking.draftCustomerName}'),
                  Text('Phone: ${booking.draftCustomerPhone}'),
                  Divider(),
                  Text('Total: \$${booking.draftTotal.toStringAsFixed(0)}',
                    style: AppTextStyles.titleMd),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Please review your booking details above.', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  void _confirmBooking(BuildContext context) async {
    final booking = context.read<BookingNotifier>();
    final apiSettings = context.read<ApiSettingsNotifier>();
    
    // Validation before confirming
    if (booking.draftServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      setState(() => _currentStep = 0);
      _pageController.jumpToPage(0);
      return;
    }

    if (booking.draftDate == null || booking.draftTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time')),
      );
      setState(() => _currentStep = 2);
      _pageController.jumpToPage(2);
      return;
    }

    final result = await booking.confirmBooking(apiSettings.baseUrl);
    if (result != null && mounted) {
      context.go('/booking-confirmation');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to confirm booking. Please check your connection.')),
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

