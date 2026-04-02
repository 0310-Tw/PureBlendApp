import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/services/token_storage_service.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TokenStorageService _tokenStorageService = TokenStorageService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  String _selectedStatusFilter = 'all';
  String? _error;
  List<dynamic> _orders = [];

  final List<String> _statusOptions = const [
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _tokenStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login again.');
      }

      final queryParameters = <String, String>{};

      if (_selectedStatusFilter != 'all') {
        queryParameters['status'] = _selectedStatusFilter;
      }

      final search = _searchController.text.trim();
      if (search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/admin/orders')
          .replace(queryParameters: queryParameters);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _orders = List<dynamic>.from(data['data'] ?? []);
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final token = await _tokenStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login again.');
      }

      final response = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/admin/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order status updated successfully')),
        );
        await _loadOrders();
      } else {
        throw Exception(data['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _showStatusDialog(Map<String, dynamic> order) async {
    String selectedStatus = (order['status'] ?? 'pending').toString();
    final orderId = int.tryParse(order['id'].toString()) ?? 0;

    if (orderId == 0) return;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map(
                      (status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status.replaceAll('_', ' ')),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setModalState(() {
                    selectedStatus = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: _isUpdating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isUpdating
                  ? null
                  : () async {
                      Navigator.pop(context);
                      await _updateOrderStatus(
                        orderId: orderId,
                        status: selectedStatus,
                      );
                    },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').trim();
  }

  String _formatAmount(dynamic amount) {
    final value = double.tryParse(amount.toString()) ?? 0;
    return value.toStringAsFixed(2);
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by order number, customer, email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.trim().isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadOrders();
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _loadOrders(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatusFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'all',
                  child: Text('All statuses'),
                ),
                ..._statusOptions.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(_formatStatus(status)),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedStatusFilter = value;
                });
                _loadOrders();
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadOrders,
                child: const Text('Apply Search / Filter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id']?.toString() ?? '';
    final orderNumber = order['order_number']?.toString() ?? 'Unknown';
    final customerName =
        order['customer_name']?.toString() ?? 'Unknown customer';
    final customerEmail = order['customer_email']?.toString() ?? '';
    final status = order['status']?.toString() ?? 'pending';
    final totalAmount = _formatAmount(order['total_amount']);
    final fulfillmentType =
        order['fulfillment_type']?.toString() ?? 'unknown';
    final paymentMethod = order['payment_method']?.toString() ?? 'unknown';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    orderNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Chip(
                  label: Text(_formatStatus(status)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Order ID: $orderId'),
            Text('Customer: $customerName'),
            if (customerEmail.isNotEmpty) Text('Email: $customerEmail'),
            Text('Fulfillment: $fulfillmentType'),
            Text('Payment: $paymentMethod'),
            Text(
              'Total: \$$totalAmount',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating
                    ? null
                    : () => _showStatusDialog(order),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        if (_orders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No orders found'),
            ),
          )
        else
          ..._orders.map(
            (order) => _buildOrderCard(
              Map<String, dynamic>.from(order as Map),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(),
      ),
    );
  }
}