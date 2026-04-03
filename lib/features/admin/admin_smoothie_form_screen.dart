import 'package:flutter/material.dart';

import 'data/admin_api_service.dart';
import 'models/admin_smoothie_model.dart';

class AdminSmoothieFormScreen extends StatefulWidget {
  final AdminSmoothieModel? smoothie;

  const AdminSmoothieFormScreen({
    super.key,
    this.smoothie,
  });

  bool get isEdit => smoothie != null;

  @override
  State<AdminSmoothieFormScreen> createState() =>
      _AdminSmoothieFormScreenState();
}

class _AdminSmoothieFormScreenState extends State<AdminSmoothieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  final AdminApiService _adminApiService = AdminApiService();

  bool _isAvailable = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final smoothie = widget.smoothie;
    if (smoothie != null) {
      _nameController.text = smoothie.name;
      _descriptionController.text = smoothie.description;
      _priceController.text = smoothie.price.toStringAsFixed(2);
      _imageUrlController.text = smoothie.imageUrl;
      _categoryController.text = smoothie.category;
      _isAvailable = smoothie.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final imageUrl = _imageUrlController.text.trim();
      final category = _categoryController.text.trim();

      if (widget.isEdit) {
        await _adminApiService.updateSmoothie(
          smoothieId: widget.smoothie!.id,
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          isAvailable: _isAvailable,
          category: category,
        );
      } else {
        await _adminApiService.createSmoothie(
          name: name,
          description: description,
          price: price,
          imageUrl: imageUrl,
          isAvailable: _isAvailable,
          category: category,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? 'Smoothie updated successfully'
                : 'Smoothie created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Save failed: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildPreview() {
    final imageUrl = _imageUrlController.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.black12,
      ),
      child: Column(
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    height: 170,
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      size: 40,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black12,
              ),
              child: const Icon(
                Icons.local_drink_rounded,
                size: 50,
              ),
            ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _nameController.text.trim().isEmpty
                  ? 'Smoothie Name'
                  : _nameController.text.trim(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _categoryController.text.trim().isEmpty
                  ? 'Category'
                  : _categoryController.text.trim(),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _priceController.text.trim().isEmpty
                  ? 'JMD 0.00'
                  : 'JMD ${_priceController.text.trim()}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEdit ? 'Edit Smoothie' : 'Add Smoothie';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildPreview(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: 'JMD ',
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Price is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _categoryController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _imageUrlController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
              title: const Text('Available'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : widget.isEdit
                          ? 'Update Smoothie'
                          : 'Create Smoothie',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}