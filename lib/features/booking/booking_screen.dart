
import 'package:flutter/material.dart';
import '../../app_theme/app_text_styles.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int currentStep = 0;

  String selectedService = '';
  String selectedStylist = '';
  String selectedTime = '';

  DateTime selectedDate = DateTime.now();
  final List<String> _services = const ['Haircut', 'Coloring', 'Styling'];
  final List<String> _stylists = const ['Emma', 'Liam', 'Sophia'];
  final List<String> _timeSlots = const ['10:00 AM', '12:00 PM', '3:00 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book an Appointment',
          style: AppTextStyles.displaySm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepContinue: () {
          if (currentStep < 4) {
            setState(() {
              currentStep++;
            });
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep--;
            });
          }
        },
        steps: [
          Step(
            title: const Text('Service'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedService.isEmpty ? null : selectedService,
              decoration: const InputDecoration(labelText: 'Select service'),
              items: _services
                  .map((service) => DropdownMenuItem(
                value: service,
                child: Text(service),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedService = value;
                  });
                }
              },
            ),
          ),

          Step(
            title: const Text('Stylist'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedStylist.isEmpty ? null : selectedStylist,
              decoration: const InputDecoration(labelText: 'Select stylist'),
              items: _stylists
                  .map((stylist) => DropdownMenuItem(
                value: stylist,
                child: Text(stylist),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStylist = value;
                  });
                }
              },
            ),
          ),

          Step(
            title: const Text('Date'),
            content: ListTile(
              title: Text(
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
            ),
          ),

          Step(
            title: const Text('Time'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedTime.isEmpty ? null : selectedTime,
              decoration: const InputDecoration(labelText: 'Select time'),
              items: _timeSlots
                  .map((slot) => DropdownMenuItem(
                value: slot,
                child: Text(slot),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedTime = value;
                  });
                }
              },
            ),
          ),

          Step(
            title: const Text('Confirmation'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service: ${selectedService.isEmpty ? 'Not selected' : selectedService}'),
                Text('Stylist: ${selectedStylist.isEmpty ? 'Not selected' : selectedStylist}'),
                Text('Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}'),
                Text('Time: ${selectedTime.isEmpty ? 'Not selected' : selectedTime}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}