import 'package:flutter/material.dart';

import '../data/admin_api_service.dart';
import '../models/admin_order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  static const routeName = '/admin-orders';

  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final AdminApiService _adminApiService = AdminApiService();

  bool _isLoading = true;
  String? _error;
  int? _updatingOrderId;
  List<AdminOrderModel> _orders = [];

  final List<String> _allowedStatuses = const [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'out_for_delivery',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _adminApiService.getAllOrders();

      if (!mounted) return;
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changeStatus(AdminOrderModel order, String newStatus) async {
    if (order.status == newStatus) return;

    setState(() {
      _updatingOrderId = order.id;
    });

    try {
      final updatedOrder = await _adminApiService.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
      );

      if (!mounted) return;

      final index = _orders.indexWhere((e) => e.id == order.id);
      if (index != -1) {
        setState(() {
          _orders[index] = updatedOrder;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order #${order.id} updated to ${updatedOrder.status}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update failed: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _updatingOrderId = null;
      });
    }
  }

  Color _statusColor(String status, BuildContext context) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.deepPurple;
      case 'ready':
        return Colors.teal;
      case 'out_for_delivery':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Orders'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrders,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh orders',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 52),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadOrders,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No orders found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'New customer orders will appear here.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          final statusColor =
                              _statusColor(order.status, context);
                          final isUpdatingThisOrder =
                              _updatingOrderId == order.id;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Order #${order.id}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Text(
                                        _formatStatus(order.status),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Customer: ${order.customerName}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (order.customerEmail.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('Email: ${order.customerEmail}'),
                                ],
                                if (order.deliveryAddress.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('Address: ${order.deliveryAddress}'),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  'Total: JMD ${order.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (order.createdAt.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text('Created: ${order.createdAt}'),
                                ],
                                const SizedBox(height: 14),
                                DropdownButtonFormField<String>(
                                  value: _allowedStatuses.contains(order.status)
                                      ? order.status
                                      : _allowedStatuses.first,
                                  decoration: const InputDecoration(
                                    labelText: 'Update Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _allowedStatuses
                                      .map(
                                        (status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(_formatStatus(status)),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: isUpdatingThisOrder
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            _changeStatus(order, value);
                                          }
                                        },
                                ),
                                if (isUpdatingThisOrder) ...[
                                  const SizedBox(height: 12),
                                  const LinearProgressIndicator(),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}