import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save Preference',
              onPressed: profileProvider.isLoading ? null : _save,
              isLoading: profileProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}