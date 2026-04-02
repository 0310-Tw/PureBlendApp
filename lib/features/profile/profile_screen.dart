import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/providers/profile_provider.dart';
import '../../core/widgets/app_loader.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileProvider.isLoading
          ? const AppLoader()
          : user == null
              ? const Center(
                  child: Text('Profile not found'),
                )
              : RefreshIndicator(
                  onRefresh: () => profileProvider.fetchProfile(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor:
                                  AppColors.primaryOrange.withOpacity(0.15),
                              child: const Icon(
                                Icons.person,
                                size: 38,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone ?? '',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_outlined),
                              title: const Text('Edit Profile'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProfile,
                                );
                                if (!mounted) return;
                                await context.read<ProfileProvider>().fetchProfile();
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.location_on_outlined),
                              title: const Text('Addresses'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.addresses,
                                );
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.settings_outlined),
                              title: const Text('Settings'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.settings,
                                );
                                if (!mounted) return;
                                await context.read<ProfileProvider>().fetchProfile();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.local_shipping_outlined),
                          title: const Text('Preferred Fulfillment'),
                          subtitle: Text(
                            user.preferredFulfillment.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<AuthProvider>().logout();
                          context.read<ProfileProvider>().clearProfile();
                          context.read<FavoriteProvider>().clearFavorites();

                          if (!context.mounted) return;
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (_) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
    );
  }
}