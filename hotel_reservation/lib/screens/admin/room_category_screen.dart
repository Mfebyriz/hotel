import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/custom_button.dart';

class RoomCategoryScreen extends StatefulWidget {
  const RoomCategoryScreen({Key? key}) : super(key: key);

  @override
  State<RoomCategoryScreen> createState() => _RoomCategoryScreenState();
}

class _RoomCategoryScreenState extends State<RoomCategoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final provider = Provider.of<RoomProvider>(context, listen: false);
    await provider.fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Kategori Kamar'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RoomProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          if (provider.error != null) {
            return custom.ErrorWidget(
              message: provider.error!,
              onRetry: _loadCategories,
            );
          }

          if (provider.categories.isEmpty) {
            return custom.EmptyWidget(
              message: 'Belum ada kategori kamar',
              icon: Icons.category_outlined,
              onAction: () {
                // TODO: Add category
                Helpers.showSnackBar(
                  context,
                  'Fitur tambah kategori coming soon!',
                );
              },
              actionText: 'Tambah Kategori',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadCategories,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppConstants.paddingMedium,
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        category.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      Helpers.formatCurrency(category.basePrice),
                      style: const TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.paddingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (category.description != null) ...[
                              Text(
                                category.description!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  size: 16,
                                  color: AppConstants.textSecondaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text('Max ${category.maxGuests} Tamu'),
                              ],
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Fasilitas:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: category.amenities.map((amenity) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppConstants.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppConstants.primaryColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // TODO: Edit category
                                      Helpers.showSnackBar(
                                        context,
                                        'Fitur edit coming soon!',
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppConstants.primaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // TODO: Delete category
                                      Helpers.showSnackBar(
                                        context,
                                        'Fitur hapus coming soon!',
                                      );
                                    },
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text('Hapus'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppConstants.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new category
          Helpers.showSnackBar(context, 'Fitur tambah kategori coming soon!');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kategori'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}