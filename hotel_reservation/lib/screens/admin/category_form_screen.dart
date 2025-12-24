import 'package:flutter/material.dart';
import '../../models/room_category.dart';
import '../../services/room_category_service.dart';

class CategoryFormScreen extends StatefulWidget {
  final RoomCategory? category;

  const CategoryFormScreen({Key? key, this.category}) : super(key: key);

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreen();
}

class _CategoryFormScreen extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _priceController.text = widget.category!.price.toString();
      _descriptionController.text = widget.category!.description ?? '';
      _imageUrlController.text = widget.category!.imageUrl ?? '';
      _capacityController.text = widget.category!.capacity.toString();
    } else {
      _capacityController.text = '2';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoryData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text),
        'descriptions': _descriptionController.text.trim(),
        'image_url': _imageUrlController.text.trim(),
        'capacity': int.parse(_capacityController.text),
      };

      if (widget.category == null) {
        await RoomCategoryService.createCategory(categoryData);
      } else {
        await RoomCategoryService.updateCategory(widget.category!.id, categoryData);
      }

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.category == null
                ? 'Kategori berhasil ditambahkan'
                : 'Kategori berhasil diupdate',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  hintText: 'Standard, Deluxe, Suitez dll',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga per Malam',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas (orang)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kapasitas tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Kapasitas harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _imageUrlController,
                decoration: const  InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.category == null ? 'Tambah Kategori' : 'Update Kategori',
                        style: const TextStyle(fontSize: 16),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}