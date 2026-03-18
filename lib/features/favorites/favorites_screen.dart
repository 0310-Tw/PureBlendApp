import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/smoothie_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FavoriteProvider>().fetchFavorites();
    });
  }

  Future<void> _removeFavorite(int smoothieId) async {
    try {
      await context.read<FavoriteProvider>().removeFavorite(smoothieId);

      if (!mounted) return;
      AppSnackbars.showSuccess(context, 'Removed from favorites');
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteProvider.isLoading
          ? const AppLoader()
          : favoriteProvider.isEmpty
              ? const EmptyStateWidget(message: 'No favorites yet')
              : RefreshIndicator(
                  onRefresh: () => favoriteProvider.fetchFavorites(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProvider.favorites.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final smoothie = favoriteProvider.favorites[index];

                      return Stack(
                        children: [
                          Positioned.fill(
                            child: SmoothieCard(
                              smoothie: smoothie,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  AppRoutes.smoothieDetails,
                                  arguments: smoothie.id,
                                );

                                if (!mounted) return;
                                await context.read<FavoriteProvider>().fetchFavorites();
                              },
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(Icons.favorite, color: Colors.red),
                                onPressed: () => _removeFavorite(smoothie.id),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}