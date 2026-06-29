import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:confetti/confetti.dart';

import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingNotifier>();
    final lastBooking = booking.upcomingBookings.firstOrNull;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.roseLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, size: 80, color: AppColors.rosePrimary),
                ),
                const SizedBox(height: 20),
                const Text('Booking Confirmed!', style: AppTextStyles.heroDisplay),
                const SizedBox(height: 12),
                const Text('Your appointment has been scheduled', style: AppTextStyles.caption),
                if (lastBooking != null) ...[
                  const SizedBox(height: 30),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Confirmation Code', style: AppTextStyles.labelMd),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.blushWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lastBooking.confirmationCode,
                              style: AppTextStyles.displaySm.copyWith(letterSpacing: 2),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.blushWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: QrImageView(
                                data: lastBooking.confirmationCode,
                                version: QrVersions.auto,
                                size: 130, // Fits nicely within your 150x150 container
                              ),
                            ),
                          ),
                          const Divider(),
                          Text(lastBooking.salonName, style: AppTextStyles.titleMd),
                          const SizedBox(height: 8),
                          ...lastBooking.serviceNames.map((s) => Text('• $s')),
                          const SizedBox(height: 8),
                          Text('Stylist: ${lastBooking.stylistName}'),
                          Text('Date: ${lastBooking.date.toString().split(' ')[0]}'),
                          Text('Time: ${lastBooking.timeSlot}'),
                          const SizedBox(height: 8),
                          Text('Total: \$${lastBooking.totalPrice.toStringAsFixed(0)}',
                            style: AppTextStyles.titleMd),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/home'),
                          icon: const Icon(Icons.home),
                          label: const Text('Back to Home'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.go('/my-bookings'),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('View My Bookings'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}

