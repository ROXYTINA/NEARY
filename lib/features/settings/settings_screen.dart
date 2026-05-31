import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salon_beauty_app/app_state/notifiers.dart';
import '../../app_state/api_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiSettings = context.watch<ApiSettingsNotifier>();
    final controller = TextEditingController(text: apiSettings.baseUrl);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(title: Text('Theme'), subtitle: Text('Light / Dark')),
          const ListTile(title: Text('Notifications')),
          const ListTile(title: Text('About')),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Developer Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ListTile(
            title: const Text('API Base URL'),
            subtitle: Text(apiSettings.baseUrl),
            trailing: const Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Edit API Base URL'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'https://192.168.1.10:8080',
                      helperText: 'Include protocol, IP/Domain, and Port',
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        final newUrl = controller.text;
                        apiSettings.updateBaseUrl(newUrl);
                        // Refresh bookings with new URL
                        context.read<BookingNotifier>().load(newUrl);
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

