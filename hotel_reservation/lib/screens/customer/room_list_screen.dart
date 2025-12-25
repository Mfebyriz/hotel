import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/room_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/customer/room_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import 'room_detail_screen.dart';

class RoomListScreen extends StatefulWidget {
  final int? categoryId;
  final String? categoryName;

  const RoomListScreen({
    Key? key,
    this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  String _searchQuery = '';
  bool _showAvailableOnly = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final roomProvider = Provider.of<RoomProvider>(context, listen: false);
    await roomProvider.fetchRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'Semua Kamar'),
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
                    hintText: 'Cari kamar...',
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

                // Filter
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        value: _showAvailableOnly,
                        onChanged: (value) {
                          setState(() {
                            _showAvailableOnly = value ?? false;
                          });
                        },
                        title: const Text(
                          'Hanya kamar tersedia',
                          style: TextStyle(fontSize: 14),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Room List
          Expanded(
            child: Consumer<RoomProvider>(
              builder: (context, roomProvider, _) {
                if (roomProvider.isLoading) {
                  return const LoadingWidget();
                }

                if (roomProvider.error != null) {
                  return custom.ErrorWidget(
                    message: roomProvider.error!,
                    onRetry: _loadRooms,
                  );
                }

                // Filter rooms
                var rooms = roomProvider.rooms;

                if (widget.categoryId != null) {
                  rooms = rooms
                      .where((room) => room.categoryId == widget.categoryId)
                      .toList();
                }

                if (_showAvailableOnly) {
                  rooms = rooms.where((room) => room.isAvailable).toList();
                }

                if (_searchQuery.isNotEmpty) {
                  rooms = rooms.where((room) {
                    final roomNumber = room.roomNumber.toLowerCase();
                    final categoryName = room.category?.name.toLowerCase() ?? '';
                    return roomNumber.contains(_searchQuery) ||
                        categoryName.contains(_searchQuery);
                  }).toList();
                }

                if (rooms.isEmpty) {
                  return const custom.EmptyWidget(
                    message: 'Tidak ada kamar yang sesuai',
                    icon: Icons.hotel_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.paddingMedium,
                        ),
                        child: RoomCard(
                          room: room,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomDetailScreen(roomId: room.id),
                              ),
                            );
                          },
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
    );
  }
}