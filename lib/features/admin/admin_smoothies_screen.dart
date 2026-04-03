import 'package:flutter/material.dart';
import 'package:frontend/features/admin/admin_smoothie_form_screen.dart';

import 'data/admin_api_service.dart';
import 'models/admin_smoothie_model.dart';

class AdminSmoothiesScreen extends StatefulWidget {
  static const routeName = '/admin-smoothies';

  const AdminSmoothiesScreen({super.key});

  @override
  State<AdminSmoothiesScreen> createState() => _AdminSmoothiesScreenState();
}

class _AdminSmoothiesScreenState extends State<AdminSmoothiesScreen> {
  final AdminApiService _adminApiService = AdminApiService();

  bool _isLoading = true;
  String? _error;
  int? _deletingSmoothieId;
  List<AdminSmoothieModel> _smoothies = [];

  @override
  void initState() {
    super.initState();
    _loadSmoothies();
  }

  Future<void> _loadSmoothies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final smoothies = await _adminApiService.getAllSmoothies();

      if (!mounted) return;
      setState(() {
        _smoothies = smoothies;
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

  Future<void> _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminSmoothieFormScreen(),
      ),
    );

    if (created == true) {
      _loadSmoothies();
    }
  }

  Future<void> _openEditForm(AdminSmoothieModel smoothie) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminSmoothieFormScreen(smoothie: smoothie),
      ),
    );

    if (updated == true) {
      _loadSmoothies();
    }
  }

  Future<void> _confirmDelete(AdminSmoothieModel smoothie) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Smoothie'),
              content: Text(
                'Are you sure you want to delete "${smoothie.name}"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete) return;

    setState(() {
      _deletingSmoothieId = smoothie.id;
    });

    try {
      await _adminApiService.deleteSmoothie(smoothie.id);

      if (!mounted) return;
      setState(() {
        _smoothies.removeWhere((e) => e.id == smoothie.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${smoothie.name}" deleted successfully'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _deletingSmoothieId = null;
      });
    }
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 28,
        child: Icon(Icons.local_drink_rounded),
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      child: imageUrl.isEmpty
          ? const Icon(Icons.local_drink_rounded)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Smoothies'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadSmoothies,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh smoothies',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Smoothie'),
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
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadSmoothies,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _smoothies.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_drink_outlined,
                              size: 54,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No smoothies found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tap "Add Smoothie" to create your first smoothie item.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadSmoothies,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _smoothies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final smoothie = _smoothies[index];
                          final isDeleting =
                              _deletingSmoothieId == smoothie.id;

                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildImage(smoothie.imageUrl),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            smoothie.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (smoothie.category.isNotEmpty)
                                            Text(
                                              smoothie.category,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                          const SizedBox(height: 6),
                                          Text(
                                            'JMD ${smoothie.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color: smoothie.isAvailable
                                                  ? Colors.green.withValues(
                                                      alpha: 0.12,
                                                    )
                                                  : Colors.red.withValues(
                                                      alpha: 0.12,
                                                    ),
                                            ),
                                            child: Text(
                                              smoothie.isAvailable
                                                  ? 'Available'
                                                  : 'Unavailable',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: smoothie.isAvailable
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (smoothie.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      smoothie.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: isDeleting
                                            ? null
                                            : () => _openEditForm(smoothie),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text('Edit'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isDeleting
                                            ? null
                                            : () => _confirmDelete(smoothie),
                                        icon: const Icon(Icons.delete_outline),
                                        label: Text(
                                          isDeleting ? 'Deleting...' : 'Delete',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isDeleting) ...[
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