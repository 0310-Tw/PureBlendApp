import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/models/address_model.dart';
import '../../core/providers/address_provider.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state_widget.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AddressProvider>().fetchAddresses();
    });
  }

  Future<void> _deleteAddress(AddressModel address) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Address'),
              content: Text('Delete "${address.label}" address?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    try {
      await context.read<AddressProvider>().deleteAddress(address.id);

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Address deleted successfully');
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _setDefault(AddressModel address) async {
    try {
      await context.read<AddressProvider>().setDefaultAddress(address.id);

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Default address updated');
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Widget _buildAddressCard(AddressModel address) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (address.isDefault)
                  const Chip(
                    label: Text('Default'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if ((address.recipientName ?? '').trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(address.recipientName!),
              ),
            if ((address.recipientPhone ?? '').trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(address.recipientPhone!),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${address.streetAddress}, ${address.town}, ${address.parish}',
              ),
            ),
            if ((address.deliveryNotes ?? '').trim().isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Notes: ${address.deliveryNotes!}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoutes.addEditAddress,
                        arguments: address,
                      );

                      if (!mounted) return;
                      await context.read<AddressProvider>().fetchAddresses();
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: address.isDefault
                        ? null
                        : () => _setDefault(address),
                    child: const Text('Set Default'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteAddress(address),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addEditAddress);

          if (!mounted) return;
          await context.read<AddressProvider>().fetchAddresses();
        },
        child: const Icon(Icons.add),
      ),
      body: addressProvider.isLoading
          ? const AppLoader()
          : addressProvider.addresses.isEmpty
              ? const EmptyStateWidget(message: 'No addresses found')
              : RefreshIndicator(
                  onRefresh: () => addressProvider.fetchAddresses(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: addressProvider.addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final address = addressProvider.addresses[index];
                      return _buildAddressCard(address);
                    },
                  ),
                ),
    );
  }
}