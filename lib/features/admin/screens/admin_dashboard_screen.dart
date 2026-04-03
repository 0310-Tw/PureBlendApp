import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const routeName = '/admin';

  const AdminDashboardScreen({super.key});

  void _openOrders(BuildContext context) {
    Navigator.pushNamed(context, '/admin-orders');
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature UI not added yet'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _AdminCardData(
        title: 'Manage Orders',
        subtitle: 'View all customer orders and update order status.',
        icon: Icons.receipt_long_rounded,
        onTap: () => _openOrders(context),
      ),
      _AdminCardData(
        title: 'Manage Users',
        subtitle: 'View and manage users when the UI is added.',
        icon: Icons.people_alt_rounded,
        onTap: () => _showComingSoon(context, 'Users'),
      ),
      _AdminCardData(
        title: 'Manage Smoothies',
        subtitle: 'Create, edit and delete smoothie products next.',
        icon: Icons.local_drink_rounded,
        onTap: () => _showComingSoon(context, 'Smoothies'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Admin Control Center',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Manage orders and prepare the rest of your admin tools from one place.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              itemCount: cards.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = cards[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: item.onTap,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Icon(item.icon, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.subtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openOrders(context),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Open Orders Manager'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminCardData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _AdminCardData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}