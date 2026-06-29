
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:salon_beauty_app/app_state/notifiers.dart';
import '../../app_state/api_settings.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';
import '../../app_widget/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final apiSettings = context.watch<ApiSettingsNotifier>();
    final auth        = context.watch<AuthNotifier>();
    final urlCtrl     = TextEditingController(text: apiSettings.baseUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTextStyles.displaySm.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),

      body: ListView(
        children: [

          // ── Profile Card ────────────────────────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.rosePrimary, AppColors.roseDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: auth.isLoggedIn
                ? Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Text(
                    (auth.fullName?.isNotEmpty == true
                        ? auth.fullName![0]
                        : auth.email?[0] ?? '?')
                        .toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.fullName ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () => _showEditProfileDialog(context, auth, apiSettings),
                ),
              ],
            )
                : Row(
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Guest User',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Sign in to book appointments',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/auth'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),

          // ── Account Section ─────────────────────────────────────
          if (auth.isLoggedIn) ...[
            _sectionHeader('Account'),
            ListTile(
              leading: const Icon(Icons.person_outline,
                  color: AppColors.rosePrimary),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showEditProfileDialog(context, auth, apiSettings),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline,
                  color: AppColors.rosePrimary),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showChangePasswordDialog(context, auth, apiSettings),
            ),
            ListTile(
              leading:
              const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.error)),
              onTap: () => _confirmLogout(context, auth),
            ),
            const Divider(),
          ],

          // ── Preferences Section ──────────────────────────────────
          _sectionHeader('Preferences'),
          ListTile(
            leading: const Icon(Icons.notifications_outlined,
                color: AppColors.rosePrimary),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: AppColors.rosePrimary, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Theme', style: TextStyle(fontSize: 16)),
                          Text('Choose your preferred appearance',
                              style: TextStyle(fontSize: 12, color: AppColors.warmGrey)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ThemeSelector(),
              ],
            ),
          ),
          const Divider(),

          // ── About Section ────────────────────────────────────────
          _sectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info_outline,
                color: AppColors.rosePrimary),
            title: const Text('About App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined,
                color: AppColors.rosePrimary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),

          // ── Developer Section ────────────────────────────────────
          _sectionHeader('Developer'),
          ListTile(
            leading: const Icon(Icons.api, color: AppColors.warmGrey),
            title: const Text('API Base URL'),
            subtitle: Text(apiSettings.baseUrl,
                style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.edit),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Edit API Base URL'),
                  content: TextField(
                    controller: urlCtrl,
                    decoration: const InputDecoration(
                      hintText: 'http://10.0.2.2:8000',
                      helperText: 'Include protocol, IP/Domain, and Port',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final newUrl = urlCtrl.text.trim();
                        apiSettings.updateBaseUrl(newUrl);
                        context.read<BookingNotifier>().load(newUrl);
                        
                        if (context.canPop()) {
                          context.pop(); 
                        } else {
                          context.go('/');
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.warmGrey,
            fontSize: 12,
            letterSpacing: 1.1)),
  );

  void _showEditProfileDialog(
      BuildContext context, AuthNotifier auth, ApiSettingsNotifier apiSettings) {
    final nameCtrl  = TextEditingController(text: auth.fullName ?? '');
    final emailCtrl = TextEditingController(text: auth.email ?? '');
    bool loading    = false;
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(error!,
                      style: const TextStyle(color: AppColors.error)),
                ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            loading
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            )
                : TextButton(
              onPressed: () async {
                setState(() { loading = true; error = null; });
                final success = await auth.updateProfile(
                  apiSettings.baseUrl,
                  fullName: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated!')),
                  );
                } else {
                  setState(() {
                    loading = false;
                    error   = 'Update failed. Please try again.';
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(
      BuildContext context, AuthNotifier auth, ApiSettingsNotifier apiSettings) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool loading      = false;
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(error!,
                      style: const TextStyle(color: AppColors.error)),
                ),
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            loading
                ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            )
                : TextButton(
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  setState(() => error = 'Passwords do not match');
                  return;
                }
                if (newCtrl.text.length < 6) {
                  setState(() => error = 'Password must be at least 6 characters');
                  return;
                }
                setState(() { loading = true; error = null; });
                final success = await auth.changePassword(
                  apiSettings.baseUrl,
                  currentPassword: currentCtrl.text,
                  newPassword: newCtrl.text,
                );
                if (success && context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed!')),
                  );
                } else {
                  setState(() {
                    loading = false;
                    error   = 'Incorrect current password.';
                  });
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthNotifier auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.logout();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}