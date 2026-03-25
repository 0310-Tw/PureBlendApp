import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/providers/address_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();

  String _fulfillmentType = 'delivery';
  String _paymentMethod = 'cash_on_delivery';
  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<CartProvider>().fetchCart();
      await context.read<AddressProvider>().fetchAddresses();

      if (!mounted) return;
      final defaultAddress = context.read<AddressProvider>().defaultAddress;
      setState(() {
        _selectedAddressId = defaultAddress?.id;
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double _deliveryFee() => _fulfillmentType == 'delivery' ? 300 : 0;

  double _total(double subtotal) => subtotal + _deliveryFee();

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();

    if (cartProvider.isEmpty) {
      AppSnackbars.showError(context, 'Your cart is empty');
      return;
    }

    if (_fulfillmentType == 'delivery' && _selectedAddressId == null) {
      AppSnackbars.showError(context, 'Please select a delivery address');
      return;
    }

    try {
      final order = await context.read<OrderProvider>().createOrder(
            fulfillmentType: _fulfillmentType,
            paymentMethod: _paymentMethod,
            addressId: _fulfillmentType == 'delivery' ? _selectedAddressId : null,
            orderNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      await context.read<CartProvider>().fetchCart();

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => route.settings.name == AppRoutes.home,
        arguments: order,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _openAddresses() async {
    await Navigator.pushNamed(context, AppRoutes.addresses);

    if (!mounted) return;

    await context.read<AddressProvider>().fetchAddresses();
    final defaultAddress = context.read<AddressProvider>().defaultAddress;

    setState(() {
      _selectedAddressId = defaultAddress?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: (cartProvider.isLoading || addressProvider.isLoading)
          ? const AppLoader()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fulfillment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment<String>(
                        value: 'delivery',
                        label: Text('Delivery'),
                        icon: Icon(Icons.delivery_dining),
                      ),
                      ButtonSegment<String>(
                        value: 'pickup',
                        label: Text('Pickup'),
                        icon: Icon(Icons.storefront),
                      ),
                    ],
                    selected: {_fulfillmentType},
                    onSelectionChanged: (value) {
                      final selected = value.first;
                      setState(() {
                        _fulfillmentType = selected;
                        _paymentMethod = selected == 'delivery'
                            ? 'cash_on_delivery'
                            : 'pay_at_pickup';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_fulfillmentType == 'delivery') ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: _openAddresses,
                          child: const Text('Manage'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (addressProvider.addresses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No addresses found. Please add an address first.',
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _openAddresses,
                              child: const Text('Open Address Book'),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedAddressId,
                        items: addressProvider.addresses.map((address) {
                          return DropdownMenuItem<int>(
                            value: address.id,
                            child: Text(
                              '${address.label} - ${address.streetAddress}, ${address.town}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAddressId = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Select delivery address',
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    items: (_fulfillmentType == 'delivery'
                            ? const [
                                DropdownMenuItem(
                                  value: 'cash_on_delivery',
                                  child: Text('Cash on Delivery'),
                                ),
                                DropdownMenuItem(
                                  value: 'card',
                                  child: Text('Card'),
                                ),
                              ]
                            : const [
                                DropdownMenuItem(
                                  value: 'pay_at_pickup',
                                  child: Text('Pay at Pickup'),
                                ),
                                DropdownMenuItem(
                                  value: 'card',
                                  child: Text('Card'),
                                ),
                              ])
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _paymentMethod = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Select payment method',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Example: Please call on arrival',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        ...cartProvider.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.name} (${item.sizeName.toUpperCase()}) x${item.quantity}',
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatJmd(item.lineTotal),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(CurrencyFormatter.formatJmd(cartProvider.subtotal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Delivery Fee'),
                            Text(CurrencyFormatter.formatJmd(_deliveryFee())),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            Text(
                              CurrencyFormatter.formatJmd(
                                _total(cartProvider.subtotal),
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'Place Order',
                    onPressed: orderProvider.isLoading ? null : _placeOrder,
                    isLoading: orderProvider.isLoading,
                  ),
                ],
              ),
            ),
    );
  }
}