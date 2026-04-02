import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/services/token_storage_service.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> _orders = {};
  Map<String, dynamic> _users = {};
  Map<String, dynamic> _smoothies = {};
  List<dynamic> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final token = await _tokenStorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/admin/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> data = {};
      if (response.body.trim().isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      }

      if (response.statusCode == 200 && data['success'] == true) {
        final dashboardData = Map<String, dynamic>.from(
          data['data'] ?? <String, dynamic>{},
        );

        if (!mounted) return;

        setState(() {
          _orders = Map<String, dynamic>.from(
            dashboardData['orders'] ?? <String, dynamic>{},
          );
          _users = Map<String, dynamic>.from(
            dashboardData['users'] ?? <String, dynamic>{},
          );
          _smoothies = Map<String, dynamic>.from(
            dashboardData['smoothies'] ?? <String, dynamic>{},
          );
          _recentOrders = List<dynamic>.from(
            dashboardData['recentOrders'] ?? <dynamic>[],
          );
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to load dashboard');
      }
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

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _formatCurrency(double value) {
    return '\$${value.toStringAsFixed(2)}';
  }

  String _formatStatus(String value) {
    if (value.trim().isEmpty) return 'Unknown';

    return value
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          return '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}';
        })
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
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
        return Colors.grey;
    }
  }

  void _openOrdersScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(),
      ),
    );
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title will be connected in the next file.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildOverviewBanner({
    required int totalOrders,
    required int totalUsers,
    required int totalSmoothies,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF43A047),
            Color(0xFF66BB6A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings_outlined,
                  color: Color(0xFF2E7D32),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Pure Blend Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Monitor orders, smoothies, and customers from one place.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMiniChip('Orders', totalOrders.toString()),
              _buildMiniChip('Users', totalUsers.toString()),
              _buildMiniChip('Smoothies', totalSmoothies.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required String helper,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  helper,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    IconData? icon,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentOrdersCard() {
    if (_recentOrders.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 12),
            const Text(
              'No recent orders found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'New admin order activity will appear here.',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: List.generate(_recentOrders.length, (index) {
          final map = Map<String, dynamic>.from(_recentOrders[index] as Map);
          final status = map['status']?.toString() ?? 'unknown';

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                leading: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  map['order_number']?.toString() ?? 'Unknown order',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(map['customer_name']?.toString() ?? 'Unknown customer'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _formatStatus(status),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(_asDouble(map['total_amount'])),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: _openOrdersScreen,
              ),
              if (index != _recentOrders.length - 1)
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.only(top: 120),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            size: 44,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load admin dashboard',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Something went wrong.',
            style: TextStyle(color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalOrders = _asInt(_orders['totalOrders']);
    final totalUsers = _asInt(_users['totalUsers']);
    final totalSmoothies = _asInt(_smoothies['totalSmoothies']);
    final totalRevenue = _asDouble(_orders['totalRevenue']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadDashboard,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else ...[
                _buildOverviewBanner(
                  totalOrders: totalOrders,
                  totalUsers: totalUsers,
                  totalSmoothies: totalSmoothies,
                ),
                const SizedBox(height: 22),
                _buildSectionHeader(
                  'Overview',
                  subtitle: 'Your current admin store metrics',
                  icon: Icons.dashboard_outlined,
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Total Orders',
                  value: totalOrders.toString(),
                  icon: Icons.shopping_bag_outlined,
                  helper: 'All orders placed in the system',
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Total Users',
                  value: totalUsers.toString(),
                  icon: Icons.people_outline,
                  helper: 'Registered app customers',
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Total Smoothies',
                  value: totalSmoothies.toString(),
                  icon: Icons.local_drink_outlined,
                  helper: 'Menu items currently tracked',
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Completed Revenue',
                  value: _formatCurrency(totalRevenue),
                  icon: Icons.attach_money_rounded,
                  helper: 'Revenue from completed orders',
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Quick Actions',
                  subtitle: 'Manage the main admin areas',
                  icon: Icons.flash_on_outlined,
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Manage Orders',
                  subtitle: 'View customer orders and update their status',
                  onTap: _openOrdersScreen,
                ),
                _buildActionTile(
                  icon: Icons.local_drink_outlined,
                  title: 'Manage Smoothies',
                  subtitle: 'Add, edit, and deactivate smoothies',
                  onTap: () => _showComingSoon('Manage Smoothies'),
                ),
                _buildActionTile(
                  icon: Icons.people_outline,
                  title: 'View Users',
                  subtitle: 'See all registered users in the app',
                  onTap: () => _showComingSoon('View Users'),
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  'Recent Orders',
                  subtitle: 'Latest activity from the store',
                  icon: Icons.history,
                ),
                const SizedBox(height: 12),
                _buildRecentOrdersCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}