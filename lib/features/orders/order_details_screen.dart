import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';
import '../../core/models/order_model.dart';
import '../../core/providers/order_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_loader.dart';

class OrderDetailsScreen extends StatefulWidget {
const OrderDetailsScreen({super.key});

@override
State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
int? _orderId;
bool _hasFetched = false;

@override
void didChangeDependencies() {
super.didChangeDependencies();

if (!_hasFetched) {
  _orderId = ModalRoute.of(context)?.settings.arguments as int?;

  if (_orderId != null) {
    Future.microtask(() {
      context.read<OrderProvider>().fetchOrderById(_orderId!);
    });
  }

  _hasFetched = true;
}


}

@override
Widget build(BuildContext context) {
final orderProvider = context.watch<OrderProvider>();
final OrderModel? order = orderProvider.selectedOrder;


return Scaffold(
  appBar: AppBar(title: const Text('Order Details')),
  body: orderProvider.isLoading
      ? const AppLoader()
      : order == null
          ? const Center(child: Text('Order not found'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ORDER HEADER
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Status: ${order.status}'),
                      const SizedBox(height: 4),
                      Text('Type: ${order.fulfillmentType}'),
                      const SizedBox(height: 4),
                      Text('Payment: ${order.paymentMethod}'),

                      if (order.orderNotes != null &&
                          order.orderNotes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${order.orderNotes}'),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ITEMS TITLE
                const Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // ITEMS LIST
                ...order.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.smoothieName),
                      subtitle: Text(
                        '${item.sizeName.toUpperCase()} • Qty: ${item.quantity}',
                      ),
                      trailing: Text(
                        CurrencyFormatter.formatJmd(item.lineTotal),
                        style: const TextStyle(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // TOTAL SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal'),
                          Text(
                            CurrencyFormatter.formatJmd(order.subtotal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Delivery Fee'),
                          Text(
                            CurrencyFormatter.formatJmd(order.deliveryFee),
                          ),
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
                            CurrencyFormatter.formatJmd(order.totalAmount),
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
              ],
            ),
);

}
}
