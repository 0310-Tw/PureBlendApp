import 'package:flutter/material.dart';
import 'package:frontend/core/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _preferredFulfillment;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = context.read<ProfileProvider>().profile;
      _preferredFulfillment = user?.preferredFulfillment ?? 'delivery';
      _initialized = true;
    }
  }

  Future<void> _save() async {
    try {
      await context.read<ProfileProvider>().updatePreferences(
            preferredFulfillment: _preferredFulfillment ?? 'delivery',
          );

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Preferences updated successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _openAdminDashboard() {
    Navigator.pushNamed(context, '/admin');
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Preference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'delivery',
                    groupValue: _preferredFulfillment,
                    title: const Text('Delivery'),
                    onChanged: (value) {
                      setState(() {
                        _preferredFulfillment = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    value: 'pickup',
                    groupValue: _preferredFulfillment,
                    title: const Text('Pickup'),
                    onChanged: (value) {
                      setState(() {
                        _preferredFulfillment = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Preference',
              onPressed: profileProvider.isLoading ? null : _save,
              isLoading: profileProvider.isLoading,
            ),
            if (authProvider.isAdmin) ...[
              const SizedBox(height: 32),
              const Text(
                'Admin',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Admin Dashboard'),
                  subtitle: const Text('Manage orders, users, and smoothies'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openAdminDashboard,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}