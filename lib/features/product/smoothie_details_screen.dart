import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colours.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../core/models/smoothie_model.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/favorite_provider.dart';
import '../../core/services/smoothie_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/snackbars.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/custom_button.dart';

class SmoothieDetailsScreen extends StatefulWidget {
  const SmoothieDetailsScreen({super.key});

  @override
  State<SmoothieDetailsScreen> createState() => _SmoothieDetailsScreenState();
}

class _SmoothieDetailsScreenState extends State<SmoothieDetailsScreen> {
  final SmoothieService _smoothieService = SmoothieService();
  final TextEditingController _notesController = TextEditingController();

  SmoothieModel? _smoothie;
  bool _isLoading = true;
  String _selectedSize = 'small';
  int _quantity = 1;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final smoothieId = ModalRoute.of(context)?.settings.arguments as int?;
    if (smoothieId != null && _smoothie == null) {
      _fetchSmoothie(smoothieId);
      Future.microtask(() {
        context.read<FavoriteProvider>().fetchFavorites();
      });
    }
  }

  Future<void> _fetchSmoothie(int smoothieId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final smoothie = await _smoothieService.getSmoothieById(smoothieId);

      String selectedSize = 'small';
      final availableSizes = smoothie.sizes.map((e) => e.sizeName).toList();

      if (!availableSizes.contains('small') && availableSizes.isNotEmpty) {
        selectedSize = availableSizes.first;
      }

      setState(() {
        _smoothie = smoothie;
        _selectedSize = selectedSize;
      });
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  double get _selectedPrice {
    if (_smoothie == null) return 0;

    for (final size in _smoothie!.sizes) {
      if (size.sizeName == _selectedSize) {
        return size.price;
      }
    }

    return _smoothie!.startingPrice;
  }

  double get _totalPrice => _selectedPrice * _quantity;

  Future<void> _addToCart() async {
    if (_smoothie == null) return;

    try {
      await context.read<CartProvider>().addToCart(
            smoothieId: _smoothie!.id,
            sizeName: _selectedSize,
            quantity: _quantity,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (!mounted) return;

      AppSnackbars.showSuccess(context, 'Added to cart successfully');

      Navigator.pushNamed(context, AppRoutes.cart);
    } catch (e) {
      if (!mounted) return;
      AppSnackbars.showError(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    if (_smoothie == null) return;

    final favoriteProvider = context.read<FavoriteProvider>();
    final wasFavorite = favoriteProvider.isFavorite(_smoothie!.id);

    try {
      await favoriteProvider.toggleFavorite(_smoothie!.id);

      if (!mounted) return;

      AppSnackbars.showSuccess(
        context,
        wasFavorite ? 'Removed from favorites' : 'Added to favorites',
      );
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
    final cartProvider = context.watch<CartProvider>();
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFavorite = _smoothie != null && favoriteProvider.isFavorite(_smoothie!.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smoothie Details'),
        actions: [
          if (_smoothie != null)
            IconButton(
              onPressed: favoriteProvider.isLoading ? null : _toggleFavorite,
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
            ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.cart);
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoader()
          : _smoothie == null
              ? const Center(child: Text('Smoothie not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryOrange,
                              AppColors.berryPink,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Icon(
                          Icons.local_drink_rounded,
                          size: 88,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _smoothie!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _smoothie!.category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _smoothie!.description ?? 'Freshly blended smoothie made to order.',
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Choose Size',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        children: _smoothie!.sizes.map((size) {
                          final isSelected = _selectedSize == size.sizeName;

                          return ChoiceChip(
                            label: Text(
                              '${size.sizeName.toUpperCase()} - ${CurrencyFormatter.formatJmd(size.price)}',
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedSize = size.sizeName;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Example: Less ice, no sugar',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatJmd(_totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomButton(
                        text: 'Add to Cart',
                        onPressed: cartProvider.isLoading ? null : _addToCart,
                        isLoading: cartProvider.isLoading,
                      ),
                    ],
                  ),
                ),
    );
  }
}