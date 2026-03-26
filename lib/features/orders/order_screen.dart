import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/order_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${order.fulfillmentType}'),
              const SizedBox(height: 4),
              Text('Status: ${order.status}'),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.formatJmd(order.totalAmount),
                style: const TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.orderDetails,
            arguments: order.id,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: orderProvider.isLoading
          ? const AppLoader()
          : orderProvider.orders.isEmpty
              ? const EmptyStateWidget(message: 'No orders found')
              : RefreshIndicator(
                  onRefresh: () => orderProvider.fetchOrders(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProvider.orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildOrderCard(orderProvider.orders[index]);
                    },
                  ),
                ),
    );
  }
}