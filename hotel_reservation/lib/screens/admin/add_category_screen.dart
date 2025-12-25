import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/room_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddCategoryScreen extends StatefulWidget {
  final int? categoryId; // Null = Add, Not Null = Edit
  final String? categoryName;
  final String? description;
  final double? basePrice;
  final int? maxGuests;
  final List<String>? amenities;
  final String? imageUrl;

  const AddCategoryScreen({
    Key? key,
    this.categoryId,
    this.categoryName,
    this.description,
    this.basePrice,
    this.maxGuests,
    this.amenities,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _maxGuestsController = TextEditingController();
  final _amenityController = TextEditingController();

  List<String> _amenities = [];
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameController.text = widget.categoryName ?? '';
      _descriptionController.text = widget.description ?? '';
      _priceController.text = widget.basePrice?.toString() ?? '';
      _maxGuestsController.text = widget.maxGuests?.toString() ?? '';
      _amenities = widget.amenities ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _amenityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Helpers.showSnackBar(
        context,
        'Gagal memilih gambar: $e',
        isError: true,
      );
    }
  }

  void _addAmenity() {
    if (_amenityController.text.isNotEmpty) {
      setState(() {
        _amenities.add(_amenityController.text);
        _amenityController.clear();
      });
    }
  }

  void _removeAmenity(int index) {
    setState(() {
      _amenities.removeAt(index);
    });
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    if (_amenities.isEmpty) {
      Helpers.showSnackBar(
        context,
        'Tambahkan minimal 1 fasilitas',
        isError: true,
      );
      return;
    }

    final provider = Provider.of<RoomProvider>(context, listen: false);

    bool success;
    if (isEdit) {
      success = await provider.updateCategory(
        categoryId: widget.categoryId!,
        name: _nameController.text,
        description: _descriptionController.text,
        basePrice: double.parse(_priceController.text),
        maxGuests: int.parse(_maxGuestsController.text),
        amenities: _amenities,
        imageUrl: _imageFile?.path, // TODO: Upload image
      );
    } else {
      success = await provider.createCategory(
        name: _nameController.text,
        description: _descriptionController.text,
        basePrice: double.parse(_priceController.text),
        maxGuests: int.parse(_maxGuestsController.text),
        amenities: _amenities,
        imageUrl: _imageFile?.path, // TODO: Upload image
      );
    }

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        isEdit ? 'Kategori berhasil diupdate' : 'Kategori berhasil ditambahkan',
      );
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(
        context,
        provider.error ?? 'Gagal menyimpan kategori',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kategori' : 'Tambah Kategori'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          children: [
            // Image Picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : widget.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Tap untuk pilih gambar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Category Name
            CustomTextField(
              label: 'Nama Kategori',
              hint: 'Contoh: Standard, Deluxe, Suite',
              controller: _nameController,
              validator: Validators.validateName,
              prefixIcon: Icons.category,
            ),

            const SizedBox(height: 16),

            // Description
            CustomTextField(
              label: 'Deskripsi',
              hint: 'Deskripsi kategori kamar',
              controller: _descriptionController,
              maxLines: 3,
              prefixIcon: Icons.description,
            ),

            const SizedBox(height: 16),

            // Base Price
            CustomTextField(
              label: 'Harga per Malam (Rp)',
              hint: 'Contoh: 500000',
              controller: _priceController,
              validator: Validators.validatePrice,
              keyboardType: TextInputType.number,
              prefixIcon: Icons.money,
            ),

            const SizedBox(height: 16),

            // Max Guests
            CustomTextField(
              label: 'Maksimal Tamu',
              hint: 'Contoh: 2',
              controller: _maxGuestsController,
              validator: (value) => Validators.validateNumber(value, min: 1),
              keyboardType: TextInputType.number,
              prefixIcon: Icons.people,
            ),

            const SizedBox(height: 24),

            // Amenities Section
            const Text(
              'Fasilitas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // Add Amenity
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amenityController,
                    decoration: InputDecoration(
                      hintText: 'Tambah fasilitas',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _addAmenity(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addAmenity,
                  icon: const Icon(Icons.add_circle),
                  color: AppConstants.primaryColor,
                  iconSize: 36,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Amenities List
            if (_amenities.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: const Text(
                  'Belum ada fasilitas',
                  style: TextStyle(color: AppConstants.textSecondaryColor),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _amenities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final amenity = entry.value;
                  return Chip(
                    label: Text(amenity),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => _removeAmenity(index),
                    backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(
                      color: AppConstants.primaryColor,
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),

            // Save Button
            Consumer<RoomProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: isEdit ? 'Update Kategori' : 'Simpan Kategori',
                  onPressed: _saveCategory,
                  isLoading: provider.isLoading,
                  icon: Icons.save,
                  width: double.infinity,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate,
          size: 60,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih Gambar',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}