import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/models/cart_item_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartProvider>().fetchCart();
    });
  }

  Future<void> _deleteItem(int id) async {
    try {
      await context.read<CartProvider>().deleteCartItem(id);

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Cart item deleted');
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _clearCart() async {
    try {
      await context.read<CartProvider>().clearCart();

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Cart cleared');
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Widget _buildCartItem(CartItemModel item) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.local_drink_rounded,
                color: AppColors.primaryOrange,
                size: 34,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${item.sizeName.toUpperCase()}  •  Qty: ${item.quantity}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${item.notes!}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatJmd(item.lineTotal),
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deleteItem(item.id),
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart (${cartProvider.itemCount})'),
        actions: [
          if (!cartProvider.isEmpty)
            TextButton(
              onPressed: cartProvider.isLoading ? null : _clearCart,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cartProvider.isLoading
          ? const AppLoader()
          : cartProvider.isEmpty
              ? const EmptyStateWidget(message: 'Your cart is empty')
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => cartProvider.fetchCart(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartProvider.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = cartProvider.items[index];
                            return _buildCartItem(item);
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatJmd(cartProvider.subtotal),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            CustomButton(
                              text: 'Proceed to Checkout',
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.checkout,
                                );
                                if (!mounted) return;
                                await context.read<CartProvider>().fetchCart();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}