import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          ListTile(title: Text('Theme'), subtitle: Text('Light / Dark')),
          ListTile(title: Text('Notifications')),
          ListTile(title: Text('About')),
        ],
      ),
    );
  }
}

