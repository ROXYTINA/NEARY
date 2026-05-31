import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_text_styles.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingNotifier>();
    final upcoming = booking.upcomingBookings;
    final past = booking.pastBookings;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: const Text('My Bookings'), bottom: const TabBar(tabs: [Tab(text: 'Upcoming'), Tab(text: 'Past')])),
        body: TabBarView(children: [
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcoming.length,
            itemBuilder: (_, i) {
              final b = upcoming[i];
              return Card(
                child: ListTile(
                  title: Text(b.salonName),
                  subtitle: Text('${b.timeSlot} · ${b.date.toLocal().toString().split(' ')[0]}'),
                  trailing: Text('\$${b.totalPrice.toStringAsFixed(0)}'),
                ),
              );
            },
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: past.length,
            itemBuilder: (_, i) {
              final b = past[i];
              return Card(
                child: ListTile(
                  title: Text(b.salonName),
                  subtitle: Text('${b.timeSlot} · ${b.date.toLocal().toString().split(' ')[0]}'),
                  trailing: Text(b.status),
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}

