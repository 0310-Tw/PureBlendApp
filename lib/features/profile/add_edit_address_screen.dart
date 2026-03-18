import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/address_model.dart';
import '../../core/providers/address_provider.dart';
import '../../core/utils/snackbars.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

class AddEditAddressScreen extends StatefulWidget {
  const AddEditAddressScreen({super.key});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _labelController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _townController = TextEditingController();
  final _parishController = TextEditingController();
  final _deliveryNotesController = TextEditingController();

  bool _isDefault = false;
  bool _initialized = false;
  AddressModel? _address;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is AddressModel) {
        _address = args;
        _labelController.text = args.label;
        _recipientNameController.text = args.recipientName ?? '';
        _recipientPhoneController.text = args.recipientPhone ?? '';
        _streetAddressController.text = args.streetAddress;
        _townController.text = args.town;
        _parishController.text = args.parish;
        _deliveryNotesController.text = args.deliveryNotes ?? '';
        _isDefault = args.isDefault;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _streetAddressController.dispose();
    _townController.dispose();
    _parishController.dispose();
    _deliveryNotesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final provider = context.read<AddressProvider>();

      if (_address == null) {
        await provider.createAddress(
          label: _labelController.text.trim(),
          recipientName: _recipientNameController.text.trim().isEmpty
              ? null
              : _recipientNameController.text.trim(),
          recipientPhone: _recipientPhoneController.text.trim().isEmpty
              ? null
              : _recipientPhoneController.text.trim(),
          streetAddress: _streetAddressController.text.trim(),
          town: _townController.text.trim(),
          parish: _parishController.text.trim(),
          deliveryNotes: _deliveryNotesController.text.trim().isEmpty
              ? null
              : _deliveryNotesController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        await provider.updateAddress(
          id: _address!.id,
          label: _labelController.text.trim(),
          recipientName: _recipientNameController.text.trim().isEmpty
              ? null
              : _recipientNameController.text.trim(),
          recipientPhone: _recipientPhoneController.text.trim().isEmpty
              ? null
              : _recipientPhoneController.text.trim(),
          streetAddress: _streetAddressController.text.trim(),
          town: _townController.text.trim(),
          parish: _parishController.text.trim(),
          deliveryNotes: _deliveryNotesController.text.trim().isEmpty
              ? null
              : _deliveryNotesController.text.trim(),
          isDefault: _isDefault,
        );
      }

      if (!mounted) return;
      AppSnackbars.showSuccess(
        context,
        _address == null
            ? 'Address added successfully'
            : 'Address updated successfully',
      );
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
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_address == null ? 'Add Address' : 'Edit Address'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _labelController,
                hintText: 'Label (Home, Work, Other)',
                validator: (value) => Validators.requiredField(value, 'Label'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _recipientNameController,
                hintText: 'Recipient Name (optional)',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _recipientPhoneController,
                hintText: 'Recipient Phone (optional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _streetAddressController,
                hintText: 'Street Address',
                validator: (value) =>
                    Validators.requiredField(value, 'Street address'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _townController,
                hintText: 'Town',
                validator: (value) => Validators.requiredField(value, 'Town'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _parishController,
                hintText: 'Parish',
                validator: (value) => Validators.requiredField(value, 'Parish'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Delivery Notes (optional)',
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                title: const Text('Set as default address'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _address == null ? 'Add Address' : 'Save Changes',
                onPressed: addressProvider.isLoading ? null : _save,
                isLoading: addressProvider.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}