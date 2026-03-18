import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/profile_provider.dart';
import '../../core/utils/snackbars.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _profileImageUrlController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final user = context.read<ProfileProvider>().profile;

      if (user != null) {
        _fullNameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.phone ?? '';
        _profileImageUrlController.text = user.profileImageUrl ?? '';
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<ProfileProvider>().updateProfile(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            profileImageUrl: _profileImageUrlController.text.trim().isEmpty
                ? null
                : _profileImageUrlController.text.trim(),
          );

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Profile updated successfully');
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _fullNameController,
                hintText: 'Full Name',
                validator: (value) => Validators.requiredField(value, 'Full name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                hintText: 'Phone',
                keyboardType: TextInputType.phone,
                validator: (value) => Validators.requiredField(value, 'Phone'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _profileImageUrlController,
                hintText: 'Profile Image URL (optional)',
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                onPressed: profileProvider.isLoading ? null : _save,
                isLoading: profileProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}