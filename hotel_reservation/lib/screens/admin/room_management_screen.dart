import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final provider = Provider.of<RoomProvider>(context, listen: false);
    await Future.wait([
      provider.fetchRooms(),
      provider.fetchCategories(),
    ]);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return AppConstants.successColor;
      case 'occupied':
        return AppConstants.primaryColor;
      case 'reserved':
        return AppConstants.warningColor;
      case 'maintenance':
        return AppConstants.errorColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Manajemen Kamar'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nomor kamar...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Status Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Semua'),
                      _buildFilterChip('available', 'Tersedia'),
                      _buildFilterChip('occupied', 'Terisi'),
                      _buildFilterChip('reserved', 'Direservasi'),
                      _buildFilterChip('maintenance', 'Maintenance'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Room List
          Expanded(
            child: Consumer<RoomProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget();
                }

                if (provider.error != null) {
                  return custom.ErrorWidget(
                    message: provider.error!,
                    onRetry: _loadRooms,
                  );
                }

                // Filter rooms
                var rooms = provider.rooms;

                if (_selectedStatus != 'all') {
                  rooms = rooms.where((r) => r.status == _selectedStatus).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  rooms = rooms.where((r) {
                    return r.roomNumber.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (rooms.isEmpty) {
                  return custom.EmptyWidget(
                    message: 'Tidak ada kamar',
                    icon: Icons.hotel_outlined,
                    onAction: () {
                      Helpers.showSnackBar(
                        context,
                        'Fitur tambah kamar coming soon!',
                      );
                    },
                    actionText: 'Tambah Kamar',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: AppConstants.paddingMedium,
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(room.status),
                            child: Text(
                              room.roomNumber,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            'Kamar ${room.roomNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                room.category?.name ?? '-',
                                style: const TextStyle(
                                  color: AppConstants.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(room.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  room.statusText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _getStatusColor(room.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppConstants.paddingMedium),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.layers,
                                        size: 16,
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Lantai ${room.floor ?? '-'}'),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  if (room.sizeSqm != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.square_foot,
                                          size: 16,
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('${room.sizeSqm} m²'),
                                      ],
                                    ),

                                  const SizedBox(height: 8),

                                  if (room.category != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.people,
                                          size: 16,
                                          color: AppConstants.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Max ${room.category!.maxGuests} Tamu'),
                                      ],
                                    ),

                                  if (room.category != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      Helpers.formatCurrency(room.category!.basePrice),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppConstants.primaryColor,
                                      ),
                                    ),
                                    const Text(
                                      'per malam',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppConstants.textSecondaryColor,
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            // TODO: Edit room
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
                                            // TODO: Delete room
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new room
          Helpers.showSnackBar(context, 'Fitur tambah kamar coming soon!');
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kamar'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStatus = value;
          });
        },
        selectedColor: AppConstants.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppConstants.textPrimaryColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}