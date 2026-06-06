import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app_state/api_settings.dart';
import '../../app_state/notifiers.dart';
import '../../app_theme/app_colors.dart';
import '../../app_theme/app_text_styles.dart';

class AuthScreen extends StatefulWidget {
  final String? redirectTo; // where to go after login
  const AuthScreen({super.key, this.redirectTo});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  bool _loading = false;
  String? _error;

  // Login fields
  final _loginEmailCtrl    = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();
  bool _loginObscure       = true;

  // Register fields
  final _regNameCtrl     = TextEditingController();
  final _regEmailCtrl    = TextEditingController();
  final _regPasswordCtrl = TextEditingController();
  final _regConfirmCtrl  = TextEditingController();
  bool _regObscure       = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _loginEmailCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNameCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email    = _loginEmailCtrl.text.trim();
    final password = _loginPasswordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final auth    = context.read<AuthNotifier>();
    final success = await auth.login(baseUrl, email, password);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      context.go(widget.redirectTo ?? '/home');
    } else {
      setState(() => _error = 'Incorrect email or password');
    }
  }

  Future<void> _register() async {
    final name     = _regNameCtrl.text.trim();
    final email    = _regEmailCtrl.text.trim();
    final password = _regPasswordCtrl.text;
    final confirm  = _regConfirmCtrl.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() { _loading = true; _error = null; });
    final baseUrl = context.read<ApiSettingsNotifier>().baseUrl;
    final auth    = context.read<AuthNotifier>();
    final success = await auth.register(baseUrl, email, password, name);
    if (!mounted) return;
    setState(() => _loading = false);
    if (success) {
      context.go(widget.redirectTo ?? '/home');
    } else {
      setState(() => _error = 'Registration failed. Email may already be in use.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.rosePrimary, AppColors.roseDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.spa, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text('Welcome',
                      style: AppTextStyles.heroDisplay
                          .copyWith(color: Colors.white)),
                  Text('Sign in or create an account to book appointments',
                      style:
                      AppTextStyles.bodyMd.copyWith(color: Colors.white70)),
                ],
              ),
            ),

            // ── Tabs ─────────────────────────────────────────────
            Container(
              color: Theme.of(context).cardColor,
              child: TabBar(
                controller: _tabs,
                tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
                indicatorColor: AppColors.rosePrimary,
                labelColor: AppColors.rosePrimary,
              ),
            ),

            // ── Error Banner ─────────────────────────────────────
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_error!,
                            style: AppTextStyles.bodyMd
                                .copyWith(color: AppColors.error))),
                  ],
                ),
              ),

            // ── Forms ─────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [_buildLoginForm(), _buildRegisterForm()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _field(
            controller: _loginEmailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _field(
            controller: _loginPasswordCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _loginObscure,
            suffixIcon: IconButton(
              icon: Icon(_loginObscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () =>
                  setState(() => _loginObscure = !_loginObscure),
            ),
          ),
          const SizedBox(height: 28),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign In',
                style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/home'),
            child: Text('Continue as guest',
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.warmGrey)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _field(
            controller: _regNameCtrl,
            label: 'Full Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _field(
            controller: _regEmailCtrl,
            label: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _field(
            controller: _regPasswordCtrl,
            label: 'Password',
            icon: Icons.lock_outline,
            obscure: _regObscure,
            suffixIcon: IconButton(
              icon: Icon(_regObscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _regObscure = !_regObscure),
            ),
          ),
          const SizedBox(height: 16),
          _field(
            controller: _regConfirmCtrl,
            label: 'Confirm Password',
            icon: Icons.lock_outline,
            obscure: _regObscure,
          ),
          const SizedBox(height: 28),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rosePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create Account',
                style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.warmGrey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rosePrimary, width: 2),
        ),
      ),
    );
  }
}