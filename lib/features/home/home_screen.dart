import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/smoothie_provider.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/section_title.dart';
import '../../core/widgets/smoothie_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SmoothieProvider>().fetchSmoothies();
    });
  }

  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.favorites);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.orders);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final smoothieProvider = context.watch<SmoothieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${authProvider.user?.fullName.split(' ').first ?? 'Guest'}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: smoothieProvider.isLoading
          ? const AppLoader()
          : RefreshIndicator(
              onRefresh: () => smoothieProvider.fetchSmoothies(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryOrange,
                          AppColors.berryPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Featured Blends',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Fresh, fruity, and made for your day.',
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'Featured Smoothies'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: smoothieProvider.featuredSmoothies.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final smoothie = smoothieProvider.featuredSmoothies[index];
                        return SizedBox(
                          width: 180,
                          child: SmoothieCard(
                            smoothie: smoothie,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.smoothieDetails,
                                arguments: smoothie.id,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionTitle(title: 'All Smoothies'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: smoothieProvider.smoothies.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final smoothie = smoothieProvider.smoothies[index];
                      return SmoothieCard(
                        smoothie: smoothie,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.smoothieDetails,
                            arguments: smoothie.id,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTap,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}