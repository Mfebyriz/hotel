import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/room_category.dart';
import '../../services/room_category_service.dart';
import 'category_form_screen.dart';
import 'category_rooms_screen.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  List<RoomCategory> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);

    try {
      final categories = await RoomCategoryService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _deleteCategory(RoomCategory category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kategori ${category.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await RoomCategoryService.deleteCategory(category.id);
        _loadCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kategori berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kamar')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryFormScreen()),
          ).then((_) => _loadCategories());
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
            ? const Center(child: Text('Belum ada kategori kamar'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return _buildCategoryCard(category);
                },
              ),
      ),
    );
  }

  Widget _buildCategoryCard(RoomCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryRoomsScreen(category: category),
            ),
          ).then((_) => _loadCategories());
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: category.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          category.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.hotel, size: 40),
                        ),
                      )
                    : const Icon(Icons.hotel, size: 40),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${category.price.toStringAsFixed(0)}/malam',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${category.capacity} orang'),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.meeting_room,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text('${category.roomsCount ?? 0} kamar'),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Kategori'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rooms',
                    child: Row(
                      children: [
                        Icon(Icons.meeting_room, size: 20),
                        SizedBox(width: 8),
                        Text('Kelola Kamar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryFormScreen(category: category),
                      ),
                    ).then((_) => _loadCategories());
                  } else if (value == 'rooms') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryRoomsScreen(category: category),
                      ),
                    ).then((_) => _loadCategories());
                  } else if (value == 'delete') {
                    _deleteCategory(category);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}